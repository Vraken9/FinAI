CREATE TABLE transactions (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Tipe transaksi
  type                  TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
  
  -- Nominal (selalu positif, dalam Rupiah integer)
  amount                BIGINT NOT NULL CHECK (amount > 0),
  
  -- Waktu: transaction_date adalah waktu menurut user (bisa backdate)
  transaction_date      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Kategori (NULL untuk transfer)
  category_id           UUID REFERENCES categories(id),
  
  -- Aset
  asset_id              UUID NOT NULL REFERENCES assets(id),          -- aset sumber (untuk transfer: aset pengirim)
  transfer_to_asset_id  UUID REFERENCES assets(id),                   -- hanya untuk type = 'transfer'
  transfer_fee          BIGINT DEFAULT 0,                              -- biaya transfer opsional
  
  -- Teks
  note                  TEXT,                                          -- catatan singkat (max 100 char)
  description           TEXT,                                          -- deskripsi detail (max 500 char)
  merchant              TEXT,                                          -- nama merchant / kontak
  
  -- Sumber pemasukan (hanya untuk type = 'income')
  income_source         TEXT,
  
  -- Recurring (NULL jika bukan recurring)
  recurring_rule_id     UUID REFERENCES recurring_rules(id),
  
  -- AI metadata
  ai_generated          BOOLEAN NOT NULL DEFAULT FALSE,               -- TRUE jika diisi oleh AI
  ai_input_type         TEXT CHECK (ai_input_type IN ('text', 'voice', 'image', NULL)),
  ai_raw_input          TEXT,                                          -- input asli user ke AI (untuk audit)
  
  -- Status (untuk recurring draft)
  status                TEXT NOT NULL DEFAULT 'confirmed'
                          CHECK (status IN ('confirmed', 'draft', 'skipped')),
  
  -- Audit
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at            TIMESTAMPTZ,                                   -- soft delete

  -- Constraints
  CONSTRAINT transfer_requires_destination
    CHECK (type != 'transfer' OR transfer_to_asset_id IS NOT NULL),
  CONSTRAINT no_self_transfer
    CHECK (asset_id != transfer_to_asset_id),
  CONSTRAINT category_required_for_non_transfer
    CHECK (type = 'transfer' OR category_id IS NOT NULL)
);

-- Indexes untuk performa query analitik
CREATE INDEX idx_transactions_user_date 
  ON transactions (user_id, transaction_date DESC) 
  WHERE deleted_at IS NULL;

CREATE INDEX idx_transactions_user_type_date 
  ON transactions (user_id, type, transaction_date DESC) 
  WHERE deleted_at IS NULL;

CREATE INDEX idx_transactions_category 
  ON transactions (user_id, category_id, transaction_date DESC) 
  WHERE deleted_at IS NULL;

CREATE INDEX idx_transactions_asset 
  ON transactions (user_id, asset_id, transaction_date DESC) 
  WHERE deleted_at IS NULL;

-- Full-text search pada catatan dan merchant
CREATE INDEX idx_transactions_note_trgm 
  ON transactions USING GIN (note gin_trgm_ops) 
  WHERE deleted_at IS NULL;

-- RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own transactions"
  ON transactions FOR ALL
  USING (auth.uid() = user_id);
