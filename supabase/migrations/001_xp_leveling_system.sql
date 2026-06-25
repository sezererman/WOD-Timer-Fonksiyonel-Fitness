-- =============================================================================
-- XP & SEVIYE SİSTEMİ — Supabase Migration
-- =============================================================================
-- Bu migration aşağıdakileri oluşturur:
--   1. user_xp_profiles tablosu
--   2. calculate_and_award_xp RPC fonksiyonu (güvenli hesaplama katmanı)
--   3. on_workout_logged trigger (otomatik XP award)
--   4. Row Level Security politikaları (hile engelleme)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. XP PROFİL TABLOSU
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_xp_profiles (
  id                 UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_xp           INTEGER     NOT NULL DEFAULT 0,
  current_level      INTEGER     NOT NULL DEFAULT 1,
  streak_days        INTEGER     NOT NULL DEFAULT 0,
  last_workout_date  DATE,
  daily_xp_today     INTEGER     NOT NULL DEFAULT 0,
  daily_xp_reset_at  DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Otomatik updated_at güncellemesi için trigger fonksiyonu
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_xp_profiles_updated_at ON public.user_xp_profiles;
CREATE TRIGGER trg_user_xp_profiles_updated_at
  BEFORE UPDATE ON public.user_xp_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Yeni kullanıcı kayıt olduğunda otomatik XP profili oluştur
CREATE OR REPLACE FUNCTION public.handle_new_user_xp_profile()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.user_xp_profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_create_xp_profile_on_signup ON auth.users;
CREATE TRIGGER trg_create_xp_profile_on_signup
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_xp_profile();

-- -----------------------------------------------------------------------------
-- 2. LEVEL HESAPLAMA YARDIMCI FONKSİYONLARI
-- -----------------------------------------------------------------------------

-- XP sabitleri (buradan değiştirerek tüm sistemi ayarlayabilirsin)
-- BASE  = 100  → Level 1->2 için gereken XP
-- GROWTH = 1.18 → Her seviye %18 daha fazla XP
CREATE OR REPLACE FUNCTION public.xp_required_for_level(p_level INTEGER)
RETURNS INTEGER LANGUAGE sql IMMUTABLE AS $$
  SELECT FLOOR(100.0 * POWER(1.18, p_level - 1))::INTEGER;
$$;

-- Toplam XP'ye göre mevcut level hesapla
CREATE OR REPLACE FUNCTION public.level_from_total_xp(p_total_xp INTEGER)
RETURNS INTEGER LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  v_level        INTEGER := 1;
  v_cumulative   INTEGER := 0;
  v_needed       INTEGER;
BEGIN
  LOOP
    v_needed := public.xp_required_for_level(v_level);
    EXIT WHEN v_cumulative + v_needed > p_total_xp;
    v_cumulative := v_cumulative + v_needed;
    v_level      := v_level + 1;
  END LOOP;
  RETURN v_level;
END;
$$;

-- -----------------------------------------------------------------------------
-- 3. ANA RPC FONKSİYONU: calculate_and_award_xp
-- -----------------------------------------------------------------------------
-- Çağrı: SELECT * FROM calculate_and_award_xp(p_workout_record_id := 'uuid');
-- Dönen değer: JSONB
--   { "xp_awarded": 120, "new_total_xp": 345, "leveled_up": true, "new_level": 5 }
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.calculate_and_award_xp(
  p_user_id           UUID,
  p_mode_name         TEXT,        -- 'amrap' | 'fortime' | 'emom' | 'tabata'
  p_total_seconds     INTEGER,     -- Gerçek antrenman süresi (saniye)
  p_rounds_completed  INTEGER,     -- AMRAP: tamamlanan round sayısı
  p_time_cap_seconds  INTEGER,     -- FOR TIME: belirlenen zaman sınırı (saniye)
  p_finished_before_cap BOOLEAN,   -- FOR TIME: süreden önce bitirildi mi?
  p_client_started_at TIMESTAMPTZ, -- İstemcinin bildirdiği başlangıç zamanı
  p_client_finished_at TIMESTAMPTZ -- İstemcinin bildirdiği bitiş zamanı
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  -- Hesaplama değişkenleri
  v_duration_seconds    INTEGER;
  v_base_xp             INTEGER := 0;
  v_amrap_bonus         INTEGER := 0;
  v_fortime_bonus       INTEGER := 0;
  v_completion_bonus    INTEGER := 0;
  v_streak_bonus        INTEGER := 0;
  v_first_daily_bonus   INTEGER := 0;
  v_total_xp_earned     INTEGER := 0;

  -- Profil değişkenleri
  v_profile             public.user_xp_profiles%ROWTYPE;
  v_old_level           INTEGER;
  v_new_total_xp        INTEGER;
  v_new_level           INTEGER;
  v_leveled_up          BOOLEAN := FALSE;
  v_today               DATE := CURRENT_DATE;

  -- Rate-limit kontrolü
  v_recent_workout_count INTEGER;
BEGIN
  -- ── GÜVENLİK KONTROL 1: Kullanıcı kendi adına mı çağırıyor? ─────────────
  IF auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE EXCEPTION 'unauthorized: caller uid does not match p_user_id';
  END IF;

  -- ── GÜVENLİK KONTROL 2: Minimum antrenman süresi (60 sn) ─────────────────
  IF p_total_seconds < 60 THEN
    RETURN jsonb_build_object(
      'xp_awarded', 0,
      'reason', 'workout_too_short',
      'new_total_xp', (SELECT total_xp FROM public.user_xp_profiles WHERE id = p_user_id)
    );
  END IF;

  -- ── GÜVENLİK KONTROL 3: Zaman damgası manipülasyonu kontrolü ─────────────
  -- İstemcinin bildirdiği süre, gerçek süreyle ±10 saniye toleransla eşleşmeli
  v_duration_seconds := EXTRACT(EPOCH FROM (p_client_finished_at - p_client_started_at))::INTEGER;
  IF ABS(v_duration_seconds - p_total_seconds) > 10 THEN
    RETURN jsonb_build_object(
      'xp_awarded', 0,
      'reason', 'timestamp_mismatch',
      'new_total_xp', (SELECT total_xp FROM public.user_xp_profiles WHERE id = p_user_id)
    );
  END IF;

  -- ── GÜVENLİK KONTROL 4: Rate Limiting (5 dakikada 3'ten fazla kayıt) ─────
  -- Bu kontrol için workout_logs tablosuna bağımlı; tablo yoksa atlanır.
  -- Uygulamada workout_logs tablosu varsa aktifleştirin:
  /*
  SELECT COUNT(*) INTO v_recent_workout_count
  FROM public.workout_logs
  WHERE user_id = p_user_id
    AND finished_at > NOW() - INTERVAL '5 minutes';

  IF v_recent_workout_count >= 3 THEN
    RETURN jsonb_build_object(
      'xp_awarded', 0,
      'reason', 'rate_limit_exceeded',
      'new_total_xp', (SELECT total_xp FROM public.user_xp_profiles WHERE id = p_user_id)
    );
  END IF;
  */

  -- ── PROFİLİ YÜKLE (yoksa oluştur) ────────────────────────────────────────
  INSERT INTO public.user_xp_profiles (id)
  VALUES (p_user_id)
  ON CONFLICT (id) DO NOTHING;

  SELECT * INTO v_profile
  FROM public.user_xp_profiles
  WHERE id = p_user_id;

  v_old_level := v_profile.current_level;

  -- ── GÜNLİK XP SIFIRLA ────────────────────────────────────────────────────
  IF v_profile.daily_xp_reset_at < v_today THEN
    UPDATE public.user_xp_profiles
    SET daily_xp_today = 0, daily_xp_reset_at = v_today
    WHERE id = p_user_id;
    v_profile.daily_xp_today := 0;
    v_profile.daily_xp_reset_at := v_today;
  END IF;

  -- ── GÜNLİK XP CAP KONTROLÜ ────────────────────────────────────────────────
  IF v_profile.daily_xp_today >= 1500 THEN
    RETURN jsonb_build_object(
      'xp_awarded', 0,
      'reason', 'daily_cap_reached',
      'new_total_xp', v_profile.total_xp
    );
  END IF;

  -- ═══════════════════════════════════════════════════════════════════════════
  -- XP HESAPLAMA
  -- ═══════════════════════════════════════════════════════════════════════════

  -- 1. TEMEL SÜRE XP: Her 1 dakika = 2 XP
  v_base_xp := (p_total_seconds / 60) * 2;

  -- 2. AMRAP BONUS: Her tur = 5 XP
  IF LOWER(p_mode_name) = 'amrap' AND p_rounds_completed > 0 THEN
    v_amrap_bonus := p_rounds_completed * 5;
  END IF;

  -- 3. FOR TIME ERKEN BİTİRME BONUSU: Kalan her 1 dakika = 8 XP
  IF LOWER(p_mode_name) = 'fortime'
     AND p_finished_before_cap
     AND p_time_cap_seconds > 0
     AND p_total_seconds < p_time_cap_seconds THEN
    v_fortime_bonus := ((p_time_cap_seconds - p_total_seconds) / 60) * 8;
  END IF;

  -- 4. EMOM / TABATA TAMAMLAMA BONUSU: 25 XP sabit
  IF LOWER(p_mode_name) IN ('emom', 'tabata') THEN
    v_completion_bonus := 25;
  END IF;

  -- 5. İLK GÜNLÜK ANTRENMAN BONUSU: 10 XP
  IF v_profile.last_workout_date IS DISTINCT FROM v_today THEN
    v_first_daily_bonus := 10;
  END IF;

  -- 6. STREAK BONUSU
  --    Dün antrenman yapıldıysa streak devam eder.
  --    Aksi halde sıfırlanır.
  IF v_profile.last_workout_date = v_today - INTERVAL '1 day' THEN
    -- Streak devam ediyor
    v_streak_bonus := LEAST((v_profile.streak_days + 1) * 3, 30); -- max 30 XP (10 gün)
  ELSE
    -- Streak kırıldı veya ilk antrenman — streak günü 0'dan başlayacak
    v_streak_bonus := 0;
  END IF;

  -- ── TOPLAM VE CAP UYGULAMA ────────────────────────────────────────────────
  v_total_xp_earned := v_base_xp
                      + v_amrap_bonus
                      + v_fortime_bonus
                      + v_completion_bonus
                      + v_first_daily_bonus
                      + v_streak_bonus;

  -- Seans başına maksimum 500 XP
  v_total_xp_earned := LEAST(v_total_xp_earned, 500);

  -- Günlük kalan kota kadar ver
  v_total_xp_earned := LEAST(v_total_xp_earned, 1500 - v_profile.daily_xp_today);

  -- ═══════════════════════════════════════════════════════════════════════════
  -- PROFİLİ GÜNCELLE
  -- ═══════════════════════════════════════════════════════════════════════════
  v_new_total_xp := v_profile.total_xp + v_total_xp_earned;
  v_new_level    := public.level_from_total_xp(v_new_total_xp);
  v_leveled_up   := v_new_level > v_old_level;

  UPDATE public.user_xp_profiles
  SET
    total_xp          = v_new_total_xp,
    current_level     = v_new_level,
    daily_xp_today    = v_profile.daily_xp_today + v_total_xp_earned,
    last_workout_date = v_today,
    streak_days       = CASE
                          WHEN v_profile.last_workout_date = v_today - INTERVAL '1 day'
                          THEN v_profile.streak_days + 1
                          ELSE 1
                        END
  WHERE id = p_user_id;

  -- ── SONUÇ ─────────────────────────────────────────────────────────────────
  RETURN jsonb_build_object(
    'xp_awarded',       v_total_xp_earned,
    'xp_breakdown', jsonb_build_object(
      'base_xp',            v_base_xp,
      'amrap_bonus',        v_amrap_bonus,
      'fortime_bonus',      v_fortime_bonus,
      'completion_bonus',   v_completion_bonus,
      'first_daily_bonus',  v_first_daily_bonus,
      'streak_bonus',       v_streak_bonus
    ),
    'new_total_xp',     v_new_total_xp,
    'old_level',        v_old_level,
    'new_level',        v_new_level,
    'leveled_up',       v_leveled_up
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------
ALTER TABLE public.user_xp_profiles ENABLE ROW LEVEL SECURITY;

-- Kullanıcı yalnızca kendi profilini OKUYABİLİR
DROP POLICY IF EXISTS "Users can read own xp profile" ON public.user_xp_profiles;
CREATE POLICY "Users can read own xp profile"
  ON public.user_xp_profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Kullanıcı hiçbir zaman doğrudan YAZAMAZ (sadece RPC üzerinden güncellenir)
-- INSERT: sadece trigger (SECURITY DEFINER) yapabilir
-- UPDATE: sadece calculate_and_award_xp (SECURITY DEFINER) yapabilir
-- DELETE: sadece CASCADE (auth.users silindikçe)

-- Topluluk leaderboard için: başkalarının level bilgisini okuma (opsiyonel)
DROP POLICY IF EXISTS "Public can read level info" ON public.user_xp_profiles;
CREATE POLICY "Public can read level info"
  ON public.user_xp_profiles
  FOR SELECT
  USING (true);  -- Herkes level görebilir (gizlilik istersen auth.uid() = id yap)

-- RPC fonksiyonuna genel erişim ver (auth guard fonksiyon içinde)
GRANT EXECUTE ON FUNCTION public.calculate_and_award_xp TO authenticated;

-- Yardımcı fonksiyonlar da erişilebilir olsun
GRANT EXECUTE ON FUNCTION public.xp_required_for_level TO authenticated;
GRANT EXECUTE ON FUNCTION public.level_from_total_xp TO authenticated;

-- =============================================================================
-- TEST SORGUSU (Dashboard'da çalıştırabilirsiniz)
-- =============================================================================
-- SELECT public.xp_required_for_level(1);   -- 100
-- SELECT public.xp_required_for_level(10);  -- ~393
-- SELECT public.level_from_total_xp(0);     -- 1
-- SELECT public.level_from_total_xp(570);   -- 5 (Çaylak sonu)
-- SELECT public.level_from_total_xp(4400);  -- 15 (Beginner sonu)
