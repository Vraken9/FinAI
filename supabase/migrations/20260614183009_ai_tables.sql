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
