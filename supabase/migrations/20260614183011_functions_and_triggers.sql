CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply ke semua tabel yang punya updated_at
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_assets_updated_at
  BEFORE UPDATE ON assets FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_transactions_updated_at
  BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_budgets_updated_at
  BEFORE UPDATE ON budgets FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_recurring_rules_updated_at
  BEFORE UPDATE ON recurring_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Digunakan oleh Edge Function AI untuk memberikan konteks ke Claude API
CREATE OR REPLACE FUNCTION get_user_financial_summary(
  p_user_id UUID,
  p_month INT DEFAULT EXTRACT(MONTH FROM NOW()),
  p_year INT DEFAULT EXTRACT(YEAR FROM NOW())
)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_balance', (
      SELECT COALESCE(SUM(current_balance), 0) 
      FROM asset_balances WHERE user_id = p_user_id
    ),
    'this_month_income', (
      SELECT COALESCE(SUM(amount), 0) FROM transactions
      WHERE user_id = p_user_id AND type = 'income'
        AND EXTRACT(MONTH FROM transaction_date) = p_month
        AND EXTRACT(YEAR FROM transaction_date) = p_year
        AND deleted_at IS NULL AND status = 'confirmed'
    ),
    'this_month_expense', (
      SELECT COALESCE(SUM(amount), 0) FROM transactions
      WHERE user_id = p_user_id AND type = 'expense'
        AND EXTRACT(MONTH FROM transaction_date) = p_month
        AND EXTRACT(YEAR FROM transaction_date) = p_year
        AND deleted_at IS NULL AND status = 'confirmed'
    ),
    'expense_by_category', (
      SELECT jsonb_agg(jsonb_build_object(
        'category_name', c.name,
        'total', SUM(t.amount),
        'budget', b.amount,
        'percentage_of_budget', CASE WHEN b.amount > 0 
          THEN ROUND(SUM(t.amount)::NUMERIC / b.amount * 100, 1)
          ELSE NULL END
      ))
      FROM transactions t
      JOIN categories c ON c.id = t.category_id
      LEFT JOIN budgets b ON b.category_id = t.category_id 
        AND b.user_id = p_user_id
        AND b.period_month = p_month AND b.period_year = p_year
      WHERE t.user_id = p_user_id AND t.type = 'expense'
        AND EXTRACT(MONTH FROM t.transaction_date) = p_month
        AND EXTRACT(YEAR FROM t.transaction_date) = p_year
        AND t.deleted_at IS NULL AND t.status = 'confirmed'
      GROUP BY c.name, b.amount
    ),
    'assets', (
      SELECT jsonb_agg(jsonb_build_object(
        'name', name, 'balance', current_balance, 'type', asset_type
      ))
      FROM asset_balances WHERE user_id = p_user_id
    )
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dipanggil oleh scheduled Edge Function setiap hari pukul 06:00 WIB
CREATE OR REPLACE FUNCTION generate_recurring_drafts()
RETURNS INT AS $$
DECLARE
  rule recurring_rules%ROWTYPE;
  draft_id UUID;
  count INT := 0;
BEGIN
  FOR rule IN 
    SELECT * FROM recurring_rules
    WHERE is_active = TRUE
      AND deleted_at IS NULL
      AND next_due_date <= CURRENT_DATE + INTERVAL '1 day' -- H-1 sudah buat draft
      AND (end_date IS NULL OR next_due_date <= end_date)
  LOOP
    -- Cek apakah draft untuk tanggal ini sudah ada
    IF NOT EXISTS (
      SELECT 1 FROM transactions
      WHERE recurring_rule_id = rule.id
        AND DATE(transaction_date) = rule.next_due_date
        AND status = 'draft'
        AND deleted_at IS NULL
    ) THEN
      -- Buat draft transaksi
      INSERT INTO transactions (
        user_id, type, amount, transaction_date, category_id,
        asset_id, transfer_to_asset_id, note, description, merchant,
        recurring_rule_id, status
      ) VALUES (
        rule.user_id, rule.transaction_type, rule.amount,
        rule.next_due_date::TIMESTAMPTZ,
        rule.category_id, rule.asset_id, rule.transfer_to_asset_id,
        rule.note, rule.description, rule.merchant,
        rule.id, 'draft'
      ) RETURNING id INTO draft_id;
      
      count := count + 1;
    END IF;
    
    -- Update next_due_date
    UPDATE recurring_rules SET
      next_due_date = CASE frequency
        WHEN 'daily'     THEN next_due_date + INTERVAL '1 day'
        WHEN 'weekly'    THEN next_due_date + INTERVAL '7 days'
        WHEN 'biweekly'  THEN next_due_date + INTERVAL '14 days'
        WHEN 'monthly'   THEN next_due_date + INTERVAL '1 month'
        WHEN 'yearly'    THEN next_due_date + INTERVAL '1 year'
      END,
      last_generated_at = NOW()
    WHERE id = rule.id;
  END LOOP;
  
  RETURN count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
