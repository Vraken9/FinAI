import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

function calculateHealthScore(summary: any): number {
  let score = 0;

  // 1. Saving rate (max 40 poin)
  const savingRate = summary.this_month_income > 0
    ? (summary.this_month_income - summary.this_month_expense) / summary.this_month_income
    : 0;
  if (savingRate >= 0.3) score += 40;
  else if (savingRate >= 0.2) score += 30;
  else if (savingRate >= 0.1) score += 20;
  else if (savingRate >= 0) score += 10;

  // 2. Budget compliance (max 30 poin)
  const budgetCategories = summary.expense_by_category?.filter((c: any) => c.budget > 0) ?? [];
  if (budgetCategories.length > 0) {
    const withinBudget = budgetCategories.filter((c: any) => c.total <= c.budget).length;
    score += Math.round((withinBudget / budgetCategories.length) * 30);
  } else {
    score += 15; // Netral jika belum set budget
  }

  // 3. Konsistensi pencatatan (max 20 poin)
  const activeDays = summary.active_days_this_month ?? 0;
  const daysElapsed = new Date().getDate();
  score += Math.round((activeDays / daysElapsed) * 20);

  // 4. Emergency fund proxy (max 10 poin)
  const monthlyExpense = summary.this_month_expense;
  if (summary.total_balance >= monthlyExpense * 6) score += 10;
  else if (summary.total_balance >= monthlyExpense * 3) score += 7;
  else if (summary.total_balance >= monthlyExpense) score += 3;

  return Math.min(100, Math.max(0, score));
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

  const { data: summary, error } = await supabase.rpc("get_user_financial_summary", {
    p_user_id: user.id
  });

  if (error) {
    return new Response(JSON.stringify({ success: false, error: "Gagal memuat data", code: "DATABASE_ERROR" }), { status: 500 });
  }

  const score = calculateHealthScore(summary);

  return new Response(JSON.stringify({
    success: true,
    data: { score }
  }), { headers: { "Content-Type": "application/json" } });
});
