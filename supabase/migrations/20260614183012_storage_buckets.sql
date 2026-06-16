INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('transaction-attachments', 'transaction-attachments', false, 5242880, ARRAY['image/jpeg', 'image/png', 'application/pdf']),
  ('user-avatars', 'user-avatars', true, 2097152, ARRAY['image/jpeg', 'image/png'])
ON CONFLICT (id) DO NOTHING;

-- transaction-attachments: hanya owner yang bisa baca/tulis
CREATE POLICY "Users can manage own attachments"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'transaction-attachments' 
    AND auth.uid()::TEXT = (storage.foldername(name))[1]
  );
