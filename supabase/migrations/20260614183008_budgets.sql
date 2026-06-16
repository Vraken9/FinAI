CREATE TABLE budgets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id   UUID NOT NULL REFERENCES categories(id),
  amount        BIGINT NOT NULL CHECK (amount > 0), -- target budget dalam Rupiah
  period_month  INT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year   INT NOT NULL CHECK (period_year >= 2020),
  carry_over    BOOLEAN NOT NULL DEFAULT FALSE, -- sisa budget terbawa ke bulan berikutnya
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Satu budget per kategori per bulan per user
  UNIQUE (user_id, category_id, period_month, period_year)
);

-- RLS
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own budgets"
  ON budgets FOR ALL
  USING (auth.uid() = user_id);


