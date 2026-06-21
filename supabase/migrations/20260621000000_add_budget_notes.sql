-- Menambahkan kolom notes pada tabel budgets
ALTER TABLE budgets ADD COLUMN notes TEXT;

-- Memperbarui view budget_progress agar mengembalikan nilai notes
DROP VIEW IF EXISTS budget_progress;

CREATE VIEW budget_progress AS
SELECT 
  b.id,
  b.user_id,
  b.category_id,
  c.name AS category_name,
  c.icon AS category_icon,
  c.color AS category_color,
  b.amount AS budget_amount,
  b.notes,
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
