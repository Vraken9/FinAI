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

  const formData = await req.formData();
  const imageFile = formData.get("image") as File;
  const defaultAssetId = formData.get("default_asset_id") as string;

  if (!imageFile) {
    return new Response(JSON.stringify({
      success: false, error: "File gambar tidak ditemukan.", code: "VALIDATION_ERROR"
    }), { status: 422 });
  }

  // Encode gambar ke base64
  const imageBuffer = await imageFile.arrayBuffer();
  const imageBase64 = btoa(String.fromCharCode(...new Uint8Array(imageBuffer)));
  const mimeType = imageFile.type || "image/jpeg";

  // Ambil kategori user
  const { data: categories } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);
  const categoryList = categories?.map(c => `${c.name} (${c.type})`).join(", ");

  // Satu request ke Gemini: baca struk + parse sekaligus
  const prompt = `Lihat gambar struk/nota/invoice ini dengan teliti.

Tugas kamu:
1. Baca semua teks yang ada di struk
2. Ekstrak informasi transaksi dari struk tersebut

Yang perlu dicari:
- TOTAL AKHIR pembayaran (bukan subtotal atau harga per item)
- Nama toko/merchant (biasanya di header struk)
- Tanggal dan waktu transaksi (jika ada)
- Item-item yang dibeli (untuk dimasukkan ke deskripsi)
- Metode pembayaran jika disebutkan

Kategori tersedia: ${categoryList}
Aturan: jika tanggal tidak ada gunakan hari ini, gunakan TOTAL AKHIR bukan jumlah item.

Balas HANYA dengan JSON valid tanpa markdown:
{
  "type": "expense",
  "amount": integer Rupiah total akhir,
  "category_name": string dari daftar kategori,
  "note": string nama merchant + ringkasan max 100 karakter,
  "description": string daftar item yang dibeli max 300 karakter,
  "merchant": string nama toko atau null,
  "transaction_date": string ISO timestamp atau null jika tidak ada di struk,
  "confidence": angka 0-1 seberapa jelas struk terbaca,
  "ambiguity": string atau null jika ada yang tidak terbaca jelas
}`;

  const rawText = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_MULTIMODAL")!,
    contents: [{
      role: "user",
      parts: [
        { inlineData: { mimeType, data: imageBase64 } },
        { text: prompt },
      ],
    }],
    generationConfig: { maxOutputTokens: 700 },
  });

  try {
    const parsed = JSON.parse(rawText.trim());
    const matchedCategory = categories?.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    // Upload foto ke Supabase Storage untuk dilampirkan ke transaksi
    const fileName = `receipt_${Date.now()}.${mimeType.split("/")[1]}`;
    const storagePath = `${user.id}/pending/${fileName}`;
    await supabase.storage
      .from("transaction-attachments")
      .upload(storagePath, imageFile, { contentType: mimeType });

    await logAiUsage(user.id, "parse_image");

    return new Response(JSON.stringify({
      success: true,
      data: {
        type: parsed.type ?? "expense",
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: defaultAssetId,
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

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "Struk tidak dapat dibaca. Pastikan foto cukup jelas dan terang, atau isi manual.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});
