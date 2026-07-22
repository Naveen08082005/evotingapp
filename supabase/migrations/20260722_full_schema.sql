-- ============================================================
-- MIGRATION: 20260722_full_schema.sql
-- E-Voting Application Database Migration
-- ============================================================

-- 1. Add is_published column to elections table
ALTER TABLE public.elections 
  ADD COLUMN IF NOT EXISTS is_published BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Add indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_elections_is_published ON public.elections(is_published);
CREATE INDEX IF NOT EXISTS idx_users_is_verified ON public.users(is_verified);

-- 3. Ensure handle_new_user auto-verifies or handles metadata correctly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (
        id, 
        email, 
        full_name, 
        register_number, 
        mobile_number, 
        department, 
        year, 
        role, 
        is_verified, 
        has_voted
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'register_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'mobile_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'department', ''),
        NEW.raw_user_meta_data->>'year',
        COALESCE(NEW.raw_user_meta_data->>'role', 'student'),
        TRUE, -- Auto-verify upon registration
        FALSE
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();
    
    RETURN NEW;
END;
$$;

-- 4. Enable RLS on notifications table if not already enabled
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark own notifications read" ON public.notifications;
DROP POLICY IF EXISTS "Admins can send notifications" ON public.notifications;

CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can mark own notifications read" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can send notifications" ON public.notifications
  FOR INSERT WITH CHECK (true);
