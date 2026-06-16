CREATE TABLE assets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT 'wallet', -- nama icon dari set icon Flutter
  color       TEXT NOT NULL DEFAULT '#185FA5', -- hex color
  asset_type  TEXT NOT NULL DEFAULT 'other'
                CHECK (asset_type IN ('cash', 'bank', 'e_wallet', 'investment', 'other')),
  initial_balance BIGINT NOT NULL DEFAULT 0, -- dalam Rupiah (integer)
  is_default  BOOLEAN NOT NULL DEFAULT FALSE, -- aset default untuk transaksi baru
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ -- soft delete
);

-- Constraint: hanya boleh 1 is_default per user
CREATE UNIQUE INDEX assets_one_default_per_user
  ON assets (user_id) WHERE is_default = TRUE AND deleted_at IS NULL;

-- RLS
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own assets"
  ON assets FOR ALL
  USING (auth.uid() = user_id);


