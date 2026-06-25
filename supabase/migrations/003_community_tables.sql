-- =============================================================================
-- TOPLULUK (COMMUNITY) TABLOLARI VE GÜVENLİK
-- users, shared_workouts, likes, comments, workout_comments, reported_comments
-- =============================================================================

-- =============================================================================
-- 1. USERS TABLOSU (Profil Bilgileri)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Yeni auth kullanıcısı kayıt olunca otomatik profil oluştur
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.users (id, name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read all profiles" ON public.users;
CREATE POLICY "Users can read all profiles"
  ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE USING (auth.uid() = id);


-- =============================================================================
-- 2. SHARED_WORKOUTS TABLOSU (Topluluk Feed)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.shared_workouts (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  workout_type     TEXT        NOT NULL,  -- 'AMRAP', 'EMOM', 'TABATA', 'FOR TIME'
  total_time       INTEGER     NOT NULL DEFAULT 0,  -- saniye cinsinden
  rounds           INTEGER     DEFAULT 0,
  notes            TEXT,
  likes_count      INTEGER     NOT NULL DEFAULT 0,
  liked_user_ids   UUID[]      NOT NULL DEFAULT '{}',
  exercises        JSONB       NOT NULL DEFAULT '[]',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE public.shared_workouts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read shared workouts" ON public.shared_workouts;
CREATE POLICY "Anyone can read shared workouts"
  ON public.shared_workouts FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert own workouts" ON public.shared_workouts;
CREATE POLICY "Users can insert own workouts"
  ON public.shared_workouts FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own workouts" ON public.shared_workouts;
CREATE POLICY "Users can delete own workouts"
  ON public.shared_workouts FOR DELETE USING (auth.uid() = user_id);


-- =============================================================================
-- 3. LIKES TABLOSU (Beğeni Sistemi)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.likes (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id  UUID        NOT NULL REFERENCES public.shared_workouts(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(workout_id, user_id)  -- Aynı kişi aynı antrenmanı 2 kez beğenemesin
);

-- RLS
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read likes" ON public.likes;
CREATE POLICY "Anyone can read likes"
  ON public.likes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can like" ON public.likes;
CREATE POLICY "Users can like"
  ON public.likes FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can unlike" ON public.likes;
CREATE POLICY "Users can unlike"
  ON public.likes FOR DELETE USING (auth.uid() = user_id);


-- =============================================================================
-- 4. COMMENTS VE WORKOUT_COMMENTS TABLOLARI
-- =============================================================================
-- comments tablosu (SupabaseSocialDataSource için)
CREATE TABLE IF NOT EXISTS public.comments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id  UUID        NOT NULL REFERENCES public.shared_workouts(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text        TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read comments" ON public.comments;
CREATE POLICY "Anyone can read comments"
  ON public.comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can add comments" ON public.comments;
CREATE POLICY "Users can add comments"
  ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;
CREATE POLICY "Users can delete own comments"
  ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- workout_comments tablosu (CommentRemoteDataSourceImpl için)
CREATE TABLE IF NOT EXISTS public.workout_comments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id  UUID        NOT NULL REFERENCES public.shared_workouts(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text        TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.workout_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read workout_comments" ON public.workout_comments;
CREATE POLICY "Anyone can read workout_comments"
  ON public.workout_comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can add workout_comments" ON public.workout_comments;
CREATE POLICY "Users can add workout_comments"
  ON public.workout_comments FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own workout_comments" ON public.workout_comments;
CREATE POLICY "Users can delete own workout_comments"
  ON public.workout_comments FOR DELETE USING (auth.uid() = user_id);


-- =============================================================================
-- 5. TOGGLE_WORKOUT_LIKE RPC FONKSİYONU
-- =============================================================================
CREATE OR REPLACE FUNCTION public.toggle_workout_like(
  p_workout_id UUID,
  p_user_id    UUID,
  p_is_liking  BOOLEAN
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_is_liking THEN
    -- Beğen
    INSERT INTO public.likes (workout_id, user_id)
    VALUES (p_workout_id, p_user_id)
    ON CONFLICT DO NOTHING;

    -- likes_count artır
    UPDATE public.shared_workouts
    SET likes_count     = likes_count + 1,
        liked_user_ids  = array_append(liked_user_ids, p_user_id)
    WHERE id = p_workout_id
      AND NOT (p_user_id = ANY(liked_user_ids));
  ELSE
    -- Beğeniyi kaldır
    DELETE FROM public.likes
    WHERE workout_id = p_workout_id AND user_id = p_user_id;

    -- likes_count azalt
    UPDATE public.shared_workouts
    SET likes_count     = GREATEST(0, likes_count - 1),
        liked_user_ids  = array_remove(liked_user_ids, p_user_id)
    WHERE id = p_workout_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.toggle_workout_like TO authenticated;


-- =============================================================================
-- 6. REPORTED_COMMENTS TABLOSU
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.reported_comments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id  UUID        NOT NULL,
  reported_by UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.reported_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can report comments" ON public.reported_comments;
CREATE POLICY "Users can report comments"
  ON public.reported_comments FOR INSERT WITH CHECK (auth.uid() = reported_by);


-- =============================================================================
-- MEVCUT KULLANICILAR İÇİN PROFİL OLUŞTURMA (Sync)
-- =============================================================================
-- public.users tablosuna eksik kayıtları ekle
INSERT INTO public.users (id)
SELECT id FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- user_xp_profiles tablosuna eksik XP profillerini ekle
INSERT INTO public.user_xp_profiles (id)
SELECT id FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- REALTIME AKTİVASYONU
-- =============================================================================
-- Supabase Studio üzerinden de yapılabilir ancak SQL ile garantiye alıyoruz.
-- (Supabase tarafında publication 'supabase_realtime' otomatik bulunur)

BEGIN;
  -- Eğer tablo önceden eklenmişse hata vermemesi için
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'likes') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.likes;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'comments') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.comments;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'workout_comments') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.workout_comments;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'user_xp_profiles') THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.user_xp_profiles;
    END IF;
  END
  $$;
COMMIT;
