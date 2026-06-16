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
