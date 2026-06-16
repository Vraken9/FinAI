# FinAI — PRD Database (Supabase / PostgreSQL)
**Versi:** 1.0.0  
**Dokumen:** PRD-01-DATABASE  
**Platform:** Supabase (PostgreSQL 15)  
**Baca PRD-00-MASTER.md terlebih dahulu.**

---

## 1. Prinsip Desain Database

1. **Soft delete everywhere** — semua tabel pakai `deleted_at TIMESTAMPTZ` bukan hard delete
2. **UUID sebagai primary key** — gunakan `gen_random_uuid()` untuk semua PK
3. **Row Level Security (RLS) wajib** — semua tabel data user diproteksi RLS
4. **Timestamp konsisten** — semua tabel punya `created_at` dan `updated_at`
5. **Semua nominal dalam integer (Rupiah penuh)** — tidak ada nilai desimal
6. **transaction_date terpisah dari created_at** — user bisa backdate transaksi

---

## 2. Entity Relationship Overview

```
users (dari Supabase Auth)
  └── user_profiles (1:1) — nama, foto, preferensi
  └── assets (1:N) — dompet/aset keuangan
  └── categories (1:N) — kategori custom
  └── transactions (1:N) — semua transaksi
        └── transaction_attachments (1:N) — foto/file
  └── budgets (1:N) — budget per kategori per bulan
  └── recurring_rules (1:N) — aturan transaksi berulang
        └── recurring_instances (1:N) — draft transaksi dari recurring
  └── ai_conversations (1:N) — riwayat chat AI
        └── ai_messages (1:N) — pesan dalam percakapan
  └── app_feedback (1:N) — feedback dari user
```

---

## 3. Schema SQL Lengkap

### 3.1 Extension & Setup

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- untuk full-text search catatan

-- Timezone default
SET timezone = 'Asia/Jakarta';
```

### 3.2 Tabel: user_profiles

```sql
CREATE TABLE user_profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL DEFAULT '',
  avatar_url    TEXT,
  currency_code CHAR(3) NOT NULL DEFAULT 'IDR',
  date_format   TEXT NOT NULL DEFAULT 'DD/MM/YYYY' 
                  CHECK (date_format IN ('DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD')),
  theme         TEXT NOT NULL DEFAULT 'system'
                  CHECK (theme IN ('light', 'dark', 'system')),
  pin_hash      TEXT, -- bcrypt hash of PIN, null jika belum setup
  biometric_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
  ai_insight_enabled   BOOLEAN NOT NULL DEFAULT TRUE,
  budget_alert_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  recurring_reminder_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own profile"
  ON user_profiles FOR ALL
  USING (auth.uid() = id);

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### 3.3 Tabel: assets (Dompet/Aset)

```sql
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
```

### 3.4 Tabel: categories (Kategori Transaksi)

```sql
CREATE TABLE categories (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL = kategori default sistem
  name         TEXT NOT NULL,
  icon         TEXT NOT NULL DEFAULT 'tag',
  color        TEXT NOT NULL DEFAULT '#888780',
  type         TEXT NOT NULL CHECK (type IN ('expense', 'income', 'both')),
  is_system    BOOLEAN NOT NULL DEFAULT FALSE, -- TRUE = kategori bawaan, tidak bisa dihapus
  is_hidden    BOOLEAN NOT NULL DEFAULT FALSE, -- user bisa sembunyikan kategori default
  sort_order   INT NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at   TIMESTAMPTZ
);

-- RLS: user bisa baca kategori sistem (user_id IS NULL) dan miliknya sendiri
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read system and own categories"
  ON categories FOR SELECT
  USING (user_id IS NULL OR auth.uid() = user_id);
CREATE POLICY "Users can modify own categories only"
  ON categories FOR INSERT UPDATE DELETE
  USING (auth.uid() = user_id);

-- Seed data: kategori default sistem
INSERT INTO categories (id, user_id, name, icon, color, type, is_system, sort_order) VALUES
-- Pengeluaran
(gen_random_uuid(), NULL, 'Makanan & Minuman', 'tools-kitchen-2', '#D85A30', 'expense', TRUE, 1),
(gen_random_uuid(), NULL, 'Transportasi', 'car', '#185FA5', 'expense', TRUE, 2),
(gen_random_uuid(), NULL, 'Kesehatan', 'heart-pulse', '#A32D2D', 'expense', TRUE, 3),
(gen_random_uuid(), NULL, 'Belanja', 'shopping-bag', '#D4537E', 'expense', TRUE, 4),
(gen_random_uuid(), NULL, 'Tagihan & Utilitas', 'bolt', '#185FA5', 'expense', TRUE, 5),
(gen_random_uuid(), NULL, 'Pendidikan', 'book', '#534AB7', 'expense', TRUE, 6),
(gen_random_uuid(), NULL, 'Hiburan', 'device-gamepad-2', '#EF9F27', 'expense', TRUE, 7),
(gen_random_uuid(), NULL, 'Perawatan Diri', 'sparkles', '#D4537E', 'expense', TRUE, 8),
(gen_random_uuid(), NULL, 'Rumah Tangga', 'home', '#63991a', 'expense', TRUE, 9),
(gen_random_uuid(), NULL, 'Lainnya', 'dots-circle-horizontal', '#888780', 'expense', TRUE, 99),
-- Pemasukan
(gen_random_uuid(), NULL, 'Gaji', 'currency-dollar', '#3B6D11', 'income', TRUE, 1),
(gen_random_uuid(), NULL, 'Freelance / Usaha', 'briefcase', '#63991a', 'income', TRUE, 2),
(gen_random_uuid(), NULL, 'Investasi', 'trending-up', '#185FA5', 'income', TRUE, 3),
(gen_random_uuid(), NULL, 'Hadiah / Bonus', 'gift', '#EF9F27', 'income', TRUE, 4),
(gen_random_uuid(), NULL, 'Lainnya', 'dots-circle-horizontal', '#888780', 'income', TRUE, 99);
```

### 3.5 Tabel: transactions (Inti — Semua Transaksi)

```sql
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
```

### 3.6 Tabel: transaction_attachments (Lampiran)

```sql
CREATE TABLE transaction_attachments (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  file_path      TEXT NOT NULL, -- path di Supabase Storage: "user_id/transaction_id/filename"
  file_name      TEXT NOT NULL,
  file_type      TEXT NOT NULL CHECK (file_type IN ('image/jpeg', 'image/png', 'application/pdf')),
  file_size_bytes INT NOT NULL,
  is_receipt     BOOLEAN NOT NULL DEFAULT FALSE, -- TRUE jika dari scan struk AI
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE transaction_attachments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own attachments"
  ON transaction_attachments FOR ALL
  USING (auth.uid() = user_id);
```

### 3.7 Tabel: budgets (Budget Per Kategori)

```sql
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
```

### 3.8 Tabel: recurring_rules (Aturan Transaksi Berulang)

```sql
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
```

### 3.9 Tabel: ai_conversations & ai_messages (Riwayat Chat)

```sql
CREATE TABLE ai_conversations (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title      TEXT, -- judul ringkasan percakapan (diisi AI)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE ai_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role            TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content         TEXT NOT NULL,
  -- Untuk pesan user yang berasal dari AI input
  input_type      TEXT CHECK (input_type IN ('text', 'voice', 'image', NULL)),
  tokens_used     INT, -- untuk monitoring biaya API
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own conversations"
  ON ai_conversations FOR ALL USING (auth.uid() = user_id);

ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access own messages"
  ON ai_messages FOR ALL USING (auth.uid() = user_id);
```

### 3.10 Tabel: app_feedback

```sql
CREATE TABLE app_feedback (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  rating      INT CHECK (rating BETWEEN 1 AND 5),
  message     TEXT,
  screen      TEXT,    -- dari halaman mana feedback dikirim
  app_version TEXT,
  platform    TEXT CHECK (platform IN ('ios', 'android')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
  -- Tidak ada RLS: data feedback boleh dibaca admin, tapi user tidak perlu baca balik
);
```

---

## 4. Database Functions & Triggers

### 4.1 Auto-update updated_at

```sql
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
```

### 4.2 Function: Summary Keuangan User (untuk Dashboard & AI)

```sql
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
```

### 4.3 Function: Generate Recurring Drafts

```sql
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
```

---

## 5. Supabase Storage Buckets

```
Bucket: transaction-attachments
- Path pattern: {user_id}/{transaction_id}/{filename}
- Max file size: 5MB
- Allowed MIME types: image/jpeg, image/png, application/pdf
- RLS: user hanya bisa akses folder miliknya sendiri

Bucket: user-avatars
- Path pattern: {user_id}/avatar.{ext}
- Max file size: 2MB
- Allowed MIME types: image/jpeg, image/png
- Public: ya (avatar boleh publik)
```

### Storage RLS Policy

```sql
-- transaction-attachments: hanya owner yang bisa baca/tulis
CREATE POLICY "Users can manage own attachments"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'transaction-attachments' 
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );
```

---

## 6. Indeks & Performa

Query paling sering dieksekusi dan index yang mendukungnya:

| Query | Index |
|---|---|
| Transaksi user bulan ini | `idx_transactions_user_date` |
| Pengeluaran per kategori bulan ini | `idx_transactions_category` |
| Saldo per aset | `idx_transactions_asset` |
| Cari transaksi berdasarkan catatan | `idx_transactions_note_trgm` |
| Budget progress bulan ini | Covered oleh view `budget_progress` |

---

## 7. Checklist Migrasi

Urutan menjalankan migration di Supabase SQL Editor:

1. Enable extensions
2. Buat tabel `user_profiles` + trigger `handle_new_user`
3. Buat tabel `assets` + view `asset_balances`
4. Buat tabel `categories` + seed data kategori default
5. Buat tabel `recurring_rules` (sebelum transactions karena FK)
6. Buat tabel `transactions` + semua index
7. Buat tabel `transaction_attachments`
8. Buat tabel `budgets` + view `budget_progress`
9. Buat tabel `ai_conversations` + `ai_messages`
10. Buat tabel `app_feedback`
11. Buat semua functions & triggers
12. Aktifkan semua RLS policies
13. Setup Storage buckets dan RLS
14. Verifikasi dengan test insert + select sebagai user biasa