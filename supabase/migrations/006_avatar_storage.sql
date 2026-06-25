-- =============================================================================
-- 006_avatar_storage.sql
-- Profil Fotoğrafı (Avatar) - Storage Bucket ve RLS Politikaları
--
-- NOT: public.users tablosunda avatar_url TEXT sütunu zaten mevcut
--      (003_community_tables.sql içinde tanımlandı). Bu migration yalnızca
--      Supabase Storage bucket'ını ve güvenlik politikalarını oluşturur.
-- =============================================================================

-- =============================================================================
-- 1. avatars BUCKET OLUŞTURMA
-- public = true → URL'ler kimlik doğrulaması olmadan okunabilir (görüntüleme için)
-- =============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- =============================================================================
-- 2. STORAGE RLS POLİTİKALARI
-- Dosya yolu formatı: {auth.uid()}/avatar.jpg
-- =============================================================================

-- SELECT: Herkes okuyabilir (public bucket)
DROP POLICY IF EXISTS "Herkes avatarlari okuyabilir" ON storage.objects;
CREATE POLICY "Herkes avatarlari okuyabilir"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- INSERT: Sadece kendi klasörüne yükleyebilir
DROP POLICY IF EXISTS "Kullaniclar kendi avatarini yukleyebilir" ON storage.objects;
CREATE POLICY "Kullaniclar kendi avatarini yukleyebilir"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- UPDATE: Sadece kendi dosyasını güncelleyebilir
DROP POLICY IF EXISTS "Kullaniclar kendi avatarini guncelleyebilir" ON storage.objects;
CREATE POLICY "Kullaniclar kendi avatarini guncelleyebilir"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- DELETE: Sadece kendi dosyasını silebilir
DROP POLICY IF EXISTS "Kullaniclar kendi avatarini silebilir" ON storage.objects;
CREATE POLICY "Kullaniclar kendi avatarini silebilir"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- =============================================================================
-- NOT: public.users.avatar_url sütunu 003_community_tables.sql'de mevcuttur.
--      Ek sütun ekleme gerekmemektedir.
-- =============================================================================
