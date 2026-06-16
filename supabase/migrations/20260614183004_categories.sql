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
  ON categories FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

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
