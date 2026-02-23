-- Create wardrobe-images storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'wardrobe-images',
  'wardrobe-images',
  true,
  10485760,  -- 10MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- RLS: Anyone can read (public bucket)
CREATE POLICY "Public read access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'wardrobe-images');

-- RLS: Users can upload to their own folder ({user_id}/*)
CREATE POLICY "Users upload to own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'wardrobe-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- RLS: Users can update their own files
CREATE POLICY "Users update own files"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'wardrobe-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- RLS: Users can delete their own files
CREATE POLICY "Users delete own files"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'wardrobe-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
