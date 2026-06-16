-- View: saldo aktual per aset (initial_balance + semua transaksi)
CREATE OR REPLACE VIEW asset_balances AS
SELECT 
  a.id,
  a.user_id,
  a.name,
  a.icon,
  a.color,
  a.asset_type,
  a.is_default,
  a.sort_order,
  a.initial_balance,
  a.initial_balance + COALESCE(
    (SELECT SUM(
      CASE 
        WHEN t.type = 'income' THEN t.amount
        WHEN t.type = 'expense' THEN -t.amount
        WHEN t.type = 'transfer' AND t.asset_id = a.id THEN -t.amount
        WHEN t.type = 'transfer' AND t.transfer_to_asset_id = a.id THEN t.amount
        ELSE 0
      END
    )
    FROM transactions t
    WHERE (t.asset_id = a.id OR t.transfer_to_asset_id = a.id)
      AND t.deleted_at IS NULL),
  0) AS current_balance
FROM assets a
WHERE a.deleted_at IS NULL;

-- View: budget progress real-time
CREATE OR REPLACE VIEW budget_progress AS
SELECT 
  b.id,
  b.user_id,
  b.category_id,
  c.name AS category_name,
  c.icon AS category_icon,
  c.color AS category_color,
  b.amount AS budget_amount,
  b.period_month,
  b.period_year,
  COALESCE(
    (SELECT SUM(t.amount)
     FROM transactions t
     WHERE t.user_id = b.user_id
       AND t.category_id = b.category_id
       AND t.type = 'expense'
       AND EXTRACT(MONTH FROM t.transaction_date) = b.period_month
       AND EXTRACT(YEAR FROM t.transaction_date) = b.period_year
       AND t.deleted_at IS NULL
       AND t.status = 'confirmed'),
  0) AS spent_amount
FROM budgets b
JOIN categories c ON c.id = b.category_id
WHERE b.user_id = auth.uid();
