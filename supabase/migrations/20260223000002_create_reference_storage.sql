INSERT INTO storage.buckets (id, name, public)
VALUES ('reference-images', 'reference-images', false);

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users upload own references"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'reference-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow authenticated users to read their own references
CREATE POLICY "Users read own references"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'reference-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
