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
