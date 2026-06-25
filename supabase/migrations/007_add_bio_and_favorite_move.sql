-- 007_add_bio_and_favorite_move.sql
-- Description: Adds `bio` and `favorite_move` to the `users` table.

-- Add bio column (max 150 chars)
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS bio VARCHAR(150);

-- Add favorite_move column (max 50 chars)
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS favorite_move VARCHAR(50);
