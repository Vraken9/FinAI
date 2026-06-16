import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as xlsx from "https://esm.sh/xlsx@0.18.5";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized", code: "UNAUTHORIZED" }), 
      { status: 401 });
  }

  const { start_date, end_date, types } = await req.json().catch(() => ({}));

  let query = supabase
    .from("transactions")
    .select("type, amount, note, description, merchant, transaction_date, categories(name), assets(name)")
    .eq("user_id", user.id)
    .is("deleted_at", null)
    .eq("status", "confirmed");

  if (start_date) query = query.gte("transaction_date", start_date);
  if (end_date) query = query.lte("transaction_date", end_date);
  if (types && types.length > 0) query = query.in("type", types);

  const { data: transactions, error } = await query.order("transaction_date", { ascending: true });

  if (error) {
    return new Response(JSON.stringify({ success: false, error: "Gagal mengambil data transaksi", code: "DATABASE_ERROR" }), { status: 500 });
  }

  const wsData = transactions.map(t => ({
    Tanggal: new Date(t.transaction_date).toLocaleDateString("id"),
    Tipe: t.type,
    Nominal: t.amount,
    Kategori: (t.categories as any)?.name ?? "-",
    Aset: (t.assets as any)?.name ?? "-",
    Merchant: t.merchant ?? "-",
    Catatan: t.note ?? "-",
    Deskripsi: t.description ?? "-"
  }));

  const wb = xlsx.utils.book_new();
  const ws = xlsx.utils.json_to_sheet(wsData);
  xlsx.utils.book_append_sheet(wb, ws, "Transaksi");

  const buf = xlsx.write(wb, { type: "buffer", bookType: "xlsx" });

  return new Response(buf, {
    headers: {
      "Content-Type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "Content-Disposition": 'attachment; filename="FinAI_Export.xlsx"'
    }
  });
});
