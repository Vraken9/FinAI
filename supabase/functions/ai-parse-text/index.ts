import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini } from "../_shared/gemini.ts";

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
    input_type: "text",
  });
}

serve(async (req) => {
  // 1. Verifikasi JWT
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized", code: "UNAUTHORIZED" }), 
      { status: 401 });
  }

  // 2. Rate limiting
  const todayUsage = await checkDailyAiUsage(user.id);
  const limit = parseInt(Deno.env.get("AI_DAILY_LIMIT_PER_USER") ?? "50");
  if (todayUsage >= limit) {
    return new Response(JSON.stringify({
      success: false,
      error: "Batas penggunaan AI harian tercapai. Coba lagi besok.",
      code: "RATE_LIMITED"
    }), { status: 429 });
  }

  // 3. Parse body
  const { text, default_asset_id } = await req.json();

  // 4. Ambil kategori user
  const { data: categories } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);

  const categoryList = categories?.map(c => `${c.name} (${c.type})`).join(", ");

  // 5. Panggil Gemini
  const systemPrompt = `Kamu adalah asisten parsing transaksi keuangan untuk aplikasi FinAI.
Tugas kamu: ekstrak informasi transaksi dari input teks bahasa Indonesia natural.

Kategori yang tersedia: ${categoryList}

Aturan parsing:
- Jika tidak ada mata uang, asumsikan Rupiah Indonesia
- "rb" atau "ribu" = dikali 1000, "jt" atau "juta" = dikali 1.000.000
- Jika ada beberapa item (misal: nasi goreng 15rb + es teh 5rb), jumlahkan totalnya
- Jika tipe transaksi tidak jelas dari konteks, asumsikan "expense"
- Jika aset tidak disebutkan, gunakan "cash"
- Merchant adalah nama toko/restoran jika disebutkan

Balas HANYA dengan JSON valid, tanpa teks tambahan, tanpa markdown code block:
{
  "type": "income" atau "expense",
  "amount": angka integer dalam Rupiah,
  "category_name": string dari daftar kategori,
  "note": string ringkasan singkat max 100 karakter,
  "description": string deskripsi detail max 200 karakter,
  "merchant": string atau null,
  "confidence": angka 0-1,
  "ambiguity": string atau null jika ada hal yang tidak yakin
}`;

  const rawText = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_TEXT")!,
    systemInstruction: systemPrompt,
    contents: [{ role: "user", parts: [{ text: `Input: "${text}"` }] }],
    generationConfig: { maxOutputTokens: 500 },
  });

  // 6. Parse JSON response
  try {
    const parsed = JSON.parse(rawText.trim());
    const matchedCategory = categories?.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    await logAiUsage(user.id, "parse_text");

    return new Response(JSON.stringify({
      success: true,
      data: {
        type: parsed.type,
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: default_asset_id,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: text,
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "AI tidak dapat memproses input ini. Coba dengan kalimat yang lebih jelas.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});
