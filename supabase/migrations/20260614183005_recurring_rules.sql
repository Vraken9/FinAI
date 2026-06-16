CREATE TABLE recurring_rules (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Template transaksi (copy dari form transaksi)
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('income', 'expense', 'transfer')),
  amount          BIGINT NOT NULL CHECK (amount > 0),
  category_id     UUID REFERENCES categories(id),
  asset_id        UUID NOT NULL REFERENCES assets(id),
  transfer_to_asset_id UUID REFERENCES assets(id),
  note            TEXT,
  description     TEXT,
  merchant        TEXT,
  
  -- Aturan pengulangan
  frequency       TEXT NOT NULL 
                    CHECK (frequency IN ('daily', 'weekly', 'biweekly', 'monthly', 'yearly')),
  day_of_month    INT CHECK (day_of_month BETWEEN 1 AND 31), -- untuk monthly: tanggal berapa
  day_of_week     INT CHECK (day_of_week BETWEEN 0 AND 6),   -- untuk weekly: 0=Minggu, 6=Sabtu
  start_date      DATE NOT NULL,
  end_date        DATE,                                        -- NULL = tidak ada batas waktu
  next_due_date   DATE NOT NULL,                              -- tanggal jatuh tempo berikutnya
  
  -- Status
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  last_generated_at TIMESTAMPTZ,                              -- kapan terakhir kali draft dibuat
  
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

-- RLS
ALTER TABLE recurring_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own recurring rules"
  ON recurring_rules FOR ALL
  USING (auth.uid() = user_id);
