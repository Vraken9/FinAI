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
