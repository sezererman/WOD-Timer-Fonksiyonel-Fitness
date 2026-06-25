-- ==========================================
-- 004_challenges_and_badges.sql
-- Challenges and remote badges schema
-- ==========================================

-- 1. DAILY WODS
CREATE TABLE public.daily_wods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    title TEXT NOT NULL,
    mode TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL,
    rounds INTEGER DEFAULT 1,
    work_seconds INTEGER NOT NULL,
    rest_seconds INTEGER DEFAULT 0,
    prepare_seconds INTEGER DEFAULT 10,
    cooldown_seconds INTEGER DEFAULT 0,
    movements JSONB DEFAULT '[]'::jsonb,
    image_url TEXT,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.daily_wods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read daily_wods" ON public.daily_wods FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert daily wods" ON public.daily_wods FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 2. BADGES
CREATE TABLE public.badges (
    id TEXT PRIMARY KEY, -- e.g., 'first_blood', 'wod_monster'
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Initial Badges
INSERT INTO public.badges (id, title, description, icon_url) VALUES 
('first_blood', 'İLK KAN', 'İlk antrenmanını tamamladın!', 'assets/icons/badges/first_blood.png'),
('endurance_warrior', 'DAYANIKLILIK SAVAŞÇISI', '30 dakika üzerinde aralıksız çalıştın!', 'assets/icons/badges/endurance.png'),
('consistency_king', 'İSTİKRAR KRALI', 'Bir haftada 5 antrenman tamamladın!', 'assets/icons/badges/consistency.png'),
('perfect_ten', 'MÜKEMMEL ONLU', 'Toplam 10 antrenmana ulaştın!', 'assets/icons/badges/ten.png')
ON CONFLICT (id) DO NOTHING;

-- RLS
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read badges" ON public.badges FOR SELECT USING (true);

-- 3. USER BADGES
CREATE TABLE public.user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    badge_id TEXT REFERENCES public.badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- RLS
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own badges" ON public.user_badges FOR SELECT USING (auth.uid() = user_id);
-- In a real app, awarding badges might be an admin-only or trigger-based insert to prevent cheating.
-- However, since clients calculate workouts, we'll allow users to insert their own badges for this demo.
CREATE POLICY "Users can insert own badges" ON public.user_badges FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Optional: Create a function/trigger to increment likes on daily_wods
-- (Skipped for simplicity, can be added later)
