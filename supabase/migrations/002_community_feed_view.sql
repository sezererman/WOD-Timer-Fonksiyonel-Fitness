-- =============================================================================
-- TOPLULUK FEED — user_xp_profiles JOIN View
-- =============================================================================
-- shared_workouts tablosunu user_xp_profiles ile JOIN eden bir view.
-- Flutter'daki WorkoutShareRemoteDataSource bu view'ı sorgulayarak
-- her post için kullanıcının tier seviyesini (current_level) otomatik alır.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- COMMUNITY FEED VIEW — Tek sorguda profil + XP bilgisi
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.community_feed_view AS
SELECT
  ws.id,
  ws.user_id,
  ws.workout_type,
  ws.total_time,
  ws.rounds,
  ws.notes,
  ws.likes_count,
  ws.liked_user_ids,
  ws.exercises,
  ws.created_at,
  -- users tablosundan profil bilgileri
  u.name        AS user_name,
  u.avatar_url  AS user_avatar_url,
  -- user_xp_profiles tablosundan tier bilgisi
  xp.current_level AS user_level,
  xp.streak_days   AS user_streak
FROM public.shared_workouts ws
LEFT JOIN public.users u
  ON u.id = ws.user_id
LEFT JOIN public.user_xp_profiles xp
  ON xp.id = ws.user_id
ORDER BY ws.created_at DESC;

-- View için RLS (satır bazlı güvenlik) — public feed herkese açık
GRANT SELECT ON public.community_feed_view TO authenticated, anon;

-- =============================================================================
-- NOT: Eğer RemoteDataSource doğrudan 'shared_workouts' tablosunu sorguluyorsa
-- ve view'e geçiş yapmak istemiyorsanız, aşağıdaki sorguyu kullanabilirsiniz:
--
--   SELECT
--     shared_workouts.*,
--     users(name, avatar_url),
--     user_xp_profiles(current_level, streak_days)
--   FROM shared_workouts
--   ORDER BY created_at DESC
--
-- Bu Supabase PostgREST embedded resource syntax'ıdır.
-- Flutter'da: supabaseClient.from('shared_workouts').select('''
--   *,
--   users(name, avatar_url),
--   user_xp_profiles(current_level, streak_days)
-- ''')
-- =============================================================================
