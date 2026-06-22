import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini, uint8ArrayToBase64 } from "../_shared/gemini.ts";

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
    .gte("created_at", today);
  return count ?? 0;
}

async function logAiUsage(userId: string, type: string) {
  await supabase.from("ai_messages").insert({
    user_id: userId,
    role: "user",
    content: type,
    input_type: "voice",
  });
}

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized", code: "UNAUTHORIZED" }), 
      { status: 401 });
  }

  const todayUsage = await checkDailyAiUsage(user.id);
  const limit = parseInt(Deno.env.get("AI_DAILY_LIMIT_PER_USER") ?? "50");
  if (todayUsage >= limit) {
    return new Response(JSON.stringify({
      success: false,
      error: "Batas penggunaan AI harian tercapai. Coba lagi besok.",
      code: "RATE_LIMITED"
    }), { status: 429 });
  }

  let audioBase64 = "";
  let defaultAssetId = "";
  let mimeType = "audio/webm";

  try {
    const body = await req.json();
    audioBase64 = body.audio_base64;
    defaultAssetId = body.default_asset_id;
    if (body.mime_type) mimeType = body.mime_type;
  } catch (e) {
    return new Response(JSON.stringify({
      success: false, error: "Format request tidak valid. Harap gunakan JSON.", code: "VALIDATION_ERROR"
    }), { status: 400 });
  }

  if (!audioBase64) {
    return new Response(JSON.stringify({
      success: false, error: "File audio tidak ditemukan.", code: "VALIDATION_ERROR"
    }), { status: 422 });
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

  // Satu request ke Gemini: transkripsi + parse sekaligus
  const prompt = `Dengarkan audio ini. Pengguna sedang menyebutkan transaksi keuangan dalam bahasa Indonesia.

Tugas kamu:
1. Transkripsi apa yang diucapkan
2. Ekstrak informasi transaksi dari ucapan tersebut

Kategori tersedia: ${categoryList}
Daftar Dompet/Aset yang tersedia: ${assetList}
Aturan: nominal tanpa mata uang = Rupiah, "rb/ribu" = x1000, "jt/juta" = x1.000.000, default tipe = expense, jika pengguna menyebut sumber dana (misal: "bayar pakai BCA") masukkan ke asset_name, jika tidak sebut aset sama sekali biarkan asset_name null.

Balas HANYA dengan JSON valid tanpa markdown:
{
  "transcription": string ucapan pengguna,
  "type": "income" atau "expense",
  "amount": integer Rupiah,
  "category_name": string dari daftar kategori,
  "asset_name": string dari daftar dompet/aset (atau null jika tidak ada),
  "note": string max 100 karakter,
  "description": string max 200 karakter,
  "merchant": string atau null,
  "confidence": angka 0-1,
  "ambiguity": string atau null
}`;

  let rawText = "";
  try {
    rawText = await callGemini({
      model: Deno.env.get("GEMINI_MODEL_MULTIMODAL")!,
      contents: [{
        role: "user",
        parts: [
          { inlineData: { mimeType, data: audioBase64 } },
          { text: prompt },
        ],
      }],
      generationConfig: { maxOutputTokens: 600 },
    });
  } catch (error) {
    console.error("Gemini API Error:", error);
    return new Response(JSON.stringify({
      success: false,
      error: "Gagal memproses audio. Layanan AI sedang sibuk atau error.",
      code: "EXTERNAL_API_ERROR",
    }), { status: 422 });
  }

  try {
    const parsed = JSON.parse(rawText.trim());
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

    await logAiUsage(user.id, "parse_voice");

    return new Response(JSON.stringify({
      success: true,
      transcription: parsed.transcription, // dikirim ke Flutter untuk ditampilkan ke user
      data: {
        type: parsed.type,
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: finalAssetId,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: parsed.transcription,
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "Suara tidak dapat diproses. Coba ucapkan lebih jelas atau isi manual.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});
