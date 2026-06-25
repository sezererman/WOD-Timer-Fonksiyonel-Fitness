-- =============================================================================
-- 005_trending_workouts_rpc.sql
-- Topluluğun Seçimi (Trending Workouts) RPC Fonksiyonları
-- =============================================================================

-- "Topluluğun Seçimi" (Challenges/WODs) için son 7 günün en çok beğenilen antrenmanları
CREATE OR REPLACE FUNCTION public.get_trending_wods()
RETURNS SETOF public.daily_wods
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT *
  FROM public.daily_wods
  WHERE date >= CURRENT_DATE - INTERVAL '7 days'
  ORDER BY likes_count DESC, date DESC
  LIMIT 10;
$$;

-- Topluluk Feed'i (shared_workouts) için son 7 günün en çok beğenilen paylaşımları
CREATE OR REPLACE FUNCTION public.get_trending_workouts()
RETURNS SETOF public.shared_workouts
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT *
  FROM public.shared_workouts
  WHERE created_at >= NOW() - INTERVAL '7 days'
  ORDER BY likes_count DESC, created_at DESC
  LIMIT 10;
$$;

-- Fonksiyonlara erişim yetkisi veriyoruz (Hem giriş yapmış hem misafir kullanıcılar)
GRANT EXECUTE ON FUNCTION public.get_trending_wods() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_trending_workouts() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_trending_wods() TO anon;
GRANT EXECUTE ON FUNCTION public.get_trending_workouts() TO anon;
