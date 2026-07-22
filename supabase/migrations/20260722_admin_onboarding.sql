-- ============================================================
-- MIGRATION: 20260722_admin_onboarding.sql
-- Admin Onboarding & Security Enhancement Migration
-- ============================================================

-- 1. Helper function to check if user is an admin
CREATE OR REPLACE FUNCTION public.is_admin(lookup_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.admins WHERE id = lookup_user_id
        UNION
        SELECT 1 FROM public.users WHERE id = lookup_user_id AND role = 'admin'
    );
END;
$$;

-- 2. Strict handle_new_user trigger locking public signups to 'student' role
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    -- Public self-registration ALWAYS defaults to student role
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
        'student', -- FORCED SECURITY LOCK: Never allow public signup as admin
        TRUE,      -- Auto-verify student profile
        FALSE
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();
    
    RETURN NEW;
END;
$$;

-- 3. RLS Policy for admins table
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view admin list" ON public.admins;
DROP POLICY IF EXISTS "Admins can manage admins" ON public.admins;

CREATE POLICY "Admins can view admin list" ON public.admins
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage admins" ON public.admins
  FOR ALL USING (public.is_admin(auth.uid()));
