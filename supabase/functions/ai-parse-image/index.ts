import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini, extractJSON } from "../_shared/gemini.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

async function checkDailyAiUsage(userId: string): Promise<number> {
  const today = new Date().toISOString().split("T")[0];
  const { count } = await supabase
    .from("ai_messages")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId)
    .in("input_type", ["image", "voice"])  // HANYA hitung scan + voice
    .gte("created_at", today);
  return count ?? 0;
}

async function logAiUsage(userId: string, type: string) {
  await supabase.from("ai_messages").insert({
    user_id: userId,
    role: "user",
    content: type,
    input_type: "image",
  });
}

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized", code: "UNAUTHORIZED" }), 
      { status: 401, headers: { "Content-Type": "application/json" } });
  }

  const todayUsage = await checkDailyAiUsage(user.id);
  const limit = parseInt(Deno.env.get("AI_DAILY_LIMIT_PER_USER") ?? "50");
  if (todayUsage >= limit) {
    return new Response(JSON.stringify({
      success: false,
      error: "Batas penggunaan AI harian tercapai. Coba lagi besok.",
      code: "RATE_LIMITED"
    }), { status: 429, headers: { "Content-Type": "application/json" } });
  }

  let imageBase64 = "";
  let defaultAssetId = "";
  let mimeType = "image/jpeg";

  try {
    const body = await req.json();
    imageBase64 = body.image_base64;
    defaultAssetId = body.default_asset_id;
    if (body.mime_type) mimeType = body.mime_type;
  } catch (e) {
    return new Response(JSON.stringify({
      success: false, error: "Format request tidak valid. Harap gunakan JSON.", code: "VALIDATION_ERROR"
    }), { status: 400, headers: { "Content-Type": "application/json" } });
  }

  if (!imageBase64) {
    return new Response(JSON.stringify({
      success: false, error: "File gambar tidak ditemukan.", code: "VALIDATION_ERROR"
    }), { status: 422, headers: { "Content-Type": "application/json" } });
  }

  // Ambil kategori dan aset user
  const { data: categories, error: categoriesError } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);
    
  if (categoriesError) {
    console.error("Error fetching categories:", categoriesError);
  }
  const safeCategories = categories ?? [];
  const categoryList = safeCategories.map(c => `${c.name} (${c.type})`).join(", ");

  const { data: assets, error: assetsError } = await supabase
    .from("assets")
    .select("id, name, asset_type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);
    
  if (assetsError) {
    console.error("Error fetching assets:", assetsError);
  }
  const safeAssets = assets ?? [];
  const assetList = safeAssets.map(a => `${a.name} (${a.asset_type})`).join(", ");

  // Satu request ke Gemini: baca struk + parse sekaligus
  const prompt = `Ekstrak informasi transaksi dari foto struk ini.
Balas HANYA dengan JSON, tanpa penjelasan apapun.
Format: {type, amount (integer rupiah, contoh: 140000), category_name, note (deskripsi singkat), merchant, asset_name (nama dompet/bank jika disebutkan, opsional)}
Jika tidak bisa dibaca, balas: {error: true}`;

  let rawText = "";
  try {
    rawText = await callGemini({
      model: Deno.env.get("GEMINI_MODEL_MULTIMODAL")!,
      contents: [{
        role: "user",
        parts: [
          { inlineData: { mimeType, data: imageBase64 } },
          { text: prompt },
        ],
      }],
      generationConfig: { 
        responseMimeType: "application/json",
        responseSchema: {
          type: "OBJECT",
          properties: {
            type: { type: "STRING", enum: ["income", "expense", "transfer"] },
            amount: { type: "INTEGER" },
            category_name: { type: "STRING" },
            note: { type: "STRING" },
            merchant: { type: "STRING" },
            asset_name: { type: "STRING" }
          },
          required: ["type", "amount"]
        }
      },
    });
  } catch (error: any) {
    console.error("Gemini API Error:", error);
    return new Response(JSON.stringify({
      success: false,
      error: `Gemini Error: ${error.message}`,
      code: "EXTERNAL_API_ERROR",
    }), { status: 422, headers: { "Content-Type": "application/json" } });
  }

  let parsed;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    // Fallback: coba bersihkan dulu
    try {
      const cleaned = extractJSON(rawText);
      parsed = JSON.parse(cleaned);
    } catch (e: any) {
      console.error("rawText yang gagal diparse:", rawText);
      return new Response(JSON.stringify({
        success: false,
        error: `Gagal parse JSON. Error: ${e.message}`,
        code: "PARSE_FAILED",
      }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  }

  try {
    const matchedCategory = safeCategories.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    let finalAssetId = defaultAssetId;
    if (parsed.asset_name) {
      const parsedAssetLower = parsed.asset_name.toLowerCase();
      const matchedAsset = safeAssets.find(a => 
        a.name.toLowerCase().includes(parsedAssetLower) || 
        parsedAssetLower.includes(a.name.toLowerCase())
      );
      if (matchedAsset) {
        finalAssetId = matchedAsset.id;
      }
    }

    // Upload storage — jika gagal, TETAP lanjut tapi tanpa attachment
    let storagePath: string | null = null;
    try {
      const fileName = `receipt_${Date.now()}.${mimeType.split("/")[1]}`;
      storagePath = `${user.id}/pending/${fileName}`;
      const dataUri = `data:${mimeType};base64,${imageBase64}`;
      const fetchRes = await fetch(dataUri);
      const imageBuffer = await fetchRes.arrayBuffer();
      await supabase.storage
        .from("transaction-attachments")
        .upload(storagePath, imageBuffer, { contentType: mimeType });
    } catch (uploadError: any) {
      console.error("Upload storage gagal (non-fatal):", uploadError);
      storagePath = null; // Transaksi tetap bisa disimpan tanpa attachment
    }

    await logAiUsage(user.id, "parse_image");

    return new Response(JSON.stringify({
      success: true,
      data: {
        type: parsed.type ?? "expense",
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: finalAssetId,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: parsed.transaction_date ?? new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: "image_scan",
        pending_attachment_path: storagePath, // Flutter pakai ini saat simpan transaksi
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch (e: any) {
    return new Response(JSON.stringify({
      success: false,
      error: `Gagal parse JSON. Teks AI: ${rawText.substring(0, 150)}... Error: ${e.message}`,
      code: "PARSE_FAILED",
    }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
});
