import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini, GeminiContent } from "../_shared/gemini.ts";

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

  const { message, history = [] } = await req.json();

  // 1. Ambil ringkasan keuangan user dari database
  const { data: summary } = await supabase.rpc("get_user_financial_summary", {
    p_user_id: user.id
  });

  // 2. Ambil 10 transaksi terbaru
  const { data: recentTx } = await supabase
    .from("transactions")
    .select("type, amount, note, merchant, transaction_date, categories(name)")
    .eq("user_id", user.id)
    .is("deleted_at", null)
    .eq("status", "confirmed")
    .order("transaction_date", { ascending: false })
    .limit(10);

  // 3. Bangun system instruction dengan konteks keuangan nyata
  const systemInstruction = `Kamu adalah FinAI Advisor, asisten keuangan personal yang cerdas dan empatik.
Kamu memiliki akses ke data keuangan nyata pengguna dan HARUS menggunakannya saat memberi saran.

DATA KEUANGAN PENGGUNA (bulan ini):
- Total saldo semua aset: Rp ${summary?.total_balance?.toLocaleString("id") ?? "0"}
- Pemasukan bulan ini: Rp ${summary?.this_month_income?.toLocaleString("id") ?? "0"}
- Pengeluaran bulan ini: Rp ${summary?.this_month_expense?.toLocaleString("id") ?? "0"}
- Pengeluaran per kategori: ${JSON.stringify(summary?.expense_by_category ?? [])}
- Aset yang dimiliki: ${JSON.stringify(summary?.assets ?? [])}

10 TRANSAKSI TERBARU:
${recentTx?.map(t =>
  `- ${t.type}: Rp ${t.amount.toLocaleString("id")} | ${(t.categories as {name:string})?.name} | ${t.note ?? "-"} | ${t.merchant ?? "-"} | ${new Date(t.transaction_date).toLocaleDateString("id")}`
).join("\n") ?? "Belum ada transaksi."}

ATURAN SARAN:
1. Selalu referensikan data nyata pengguna, bukan asumsi umum
2. Jika ditanya soal pembelian baru, cek apakah sudah ada pembelian serupa bulan ini
3. Berikan saran yang realistis dan spesifik dalam Rupiah Indonesia
4. Gunakan bahasa Indonesia yang natural dan hangat, tidak kaku
5. Jangan menghakimi, tapi jujur dan to-the-point
6. Jika data tidak cukup untuk menjawab, katakan dengan jelas
7. Respons maksimal 3 paragraf pendek agar mudah dibaca di layar mobile`;

  // 4. Bangun riwayat percakapan untuk Gemini (multi-turn)
  const contents: GeminiContent[] = [
    ...history.map((h: any) => ({
      role: h.role as "user" | "model",
      parts: [{ text: h.text }],
    })),
    { role: "user", parts: [{ text: message }] },
  ];

  // 5. Panggil Gemini
  try {
    const aiResponse = await callGemini({
      model: Deno.env.get("GEMINI_MODEL_TEXT")!,
      systemInstruction,
      contents,
      generationConfig: { maxOutputTokens: 1024, temperature: 0.7 },
    });

    // 6. Simpan pesan ke database
    await supabase.from("ai_messages").insert([
      { user_id: user.id, role: "user", content: message, input_type: "text" },
      { user_id: user.id, role: "assistant", content: aiResponse },
    ]);

    return new Response(JSON.stringify({
      success: true,
      response: aiResponse,
    }), { headers: { "Content-Type": "application/json" } });
  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: "AI sedang sibuk. Coba lagi nanti.",
      code: "EXTERNAL_API_ERROR",
    }), { status: 503 });
  }
});
