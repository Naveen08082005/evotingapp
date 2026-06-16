-- ============================================================
-- E-VOTING SYSTEM — ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================
-- Run this in Supabase SQL Editor AFTER running schema.sql
-- ============================================================

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
ALTER TABLE public.admins                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.elections             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidates            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Helper function: check if current user is admin
-- ============================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.admins
        WHERE id = auth.uid()
    );
END;
$$;

-- ============================================================
-- POLICIES: admins table
-- ============================================================
-- Admins can read their own record
CREATE POLICY "admins_select_own" ON public.admins
    FOR SELECT USING (id = auth.uid());

-- Only service role can insert admins (setup via SQL editor)
CREATE POLICY "admins_insert_service" ON public.admins
    FOR INSERT WITH CHECK (public.is_admin());

-- ============================================================
-- POLICIES: users table
-- ============================================================
-- Admins can read all users
CREATE POLICY "users_select_admin" ON public.users
    FOR SELECT USING (public.is_admin());

-- Students can read their own record
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT USING (id = auth.uid());

-- Students can insert their own profile
CREATE POLICY "users_insert_own" ON public.users
    FOR INSERT WITH CHECK (id = auth.uid());

-- Students can update their own record
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Admins can update any user (e.g. verify)
CREATE POLICY "users_update_admin" ON public.users
    FOR UPDATE USING (public.is_admin());

-- ============================================================
-- POLICIES: elections table
-- ============================================================
-- Anyone authenticated can read elections
CREATE POLICY "elections_select_authenticated" ON public.elections
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can insert elections
CREATE POLICY "elections_insert_admin" ON public.elections
    FOR INSERT WITH CHECK (public.is_admin());

-- Only admins can update elections
CREATE POLICY "elections_update_admin" ON public.elections
    FOR UPDATE USING (public.is_admin());

-- Only admins can delete elections
CREATE POLICY "elections_delete_admin" ON public.elections
    FOR DELETE USING (public.is_admin());

-- ============================================================
-- POLICIES: candidates table
-- ============================================================
-- Authenticated users can read approved candidates
CREATE POLICY "candidates_select_approved" ON public.candidates
    FOR SELECT USING (
        status = 'approved' OR public.is_admin()
    );

-- Only admins can insert candidates
CREATE POLICY "candidates_insert_admin" ON public.candidates
    FOR INSERT WITH CHECK (public.is_admin());

-- Only admins can update candidates
CREATE POLICY "candidates_update_admin" ON public.candidates
    FOR UPDATE USING (public.is_admin());

-- Only admins can delete candidates
CREATE POLICY "candidates_delete_admin" ON public.candidates
    FOR DELETE USING (public.is_admin());

-- Allow the increment_vote_count RPC to update vote_count
-- (handled by SECURITY DEFINER on the function)

-- ============================================================
-- POLICIES: votes table
-- ============================================================
-- Admins can read all votes
CREATE POLICY "votes_select_admin" ON public.votes
    FOR SELECT USING (public.is_admin());

-- Users can read their own vote
CREATE POLICY "votes_select_own" ON public.votes
    FOR SELECT USING (user_id = auth.uid());

-- Authenticated users can insert ONE vote (unique constraint enforces once-per-election)
CREATE POLICY "votes_insert_own" ON public.votes
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid()
            AND is_verified = TRUE
            AND has_voted = FALSE
        ) AND
        EXISTS (
            SELECT 1 FROM public.elections
            WHERE id = election_id
            AND status = 'active'
        )
    );

-- Only admins can delete votes (election reset)
-- Only admins can delete votes (election reset)
CREATE POLICY "votes_delete_admin" ON public.votes
    FOR DELETE USING (public.is_admin());

-- ============================================================
-- POLICIES: verification_settings table
-- ============================================================
-- Anyone authenticated can read settings
CREATE POLICY "verification_settings_select" ON public.verification_settings
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can update settings
CREATE POLICY "verification_settings_update_admin" ON public.verification_settings
    FOR UPDATE USING (public.is_admin());

-- Only admins can insert settings
CREATE POLICY "verification_settings_insert_admin" ON public.verification_settings
    FOR INSERT WITH CHECK (public.is_admin());

-- ============================================================
-- POLICIES: notifications table
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Admins can select all notifications
CREATE POLICY "notifications_select_admin" ON public.notifications
    FOR SELECT USING (public.is_admin());

-- Students can select their own notifications OR global notifications (user_id IS NULL)
CREATE POLICY "notifications_select_user" ON public.notifications
    FOR SELECT USING (
        user_id = auth.uid() OR user_id IS NULL
    );

-- Only admins can insert notifications
CREATE POLICY "notifications_insert_admin" ON public.notifications
    FOR INSERT WITH CHECK (public.is_admin());

-- Students can update read status of their own notifications
CREATE POLICY "notifications_update_user" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Only admins can delete notifications
CREATE POLICY "notifications_delete_admin" ON public.notifications
    FOR DELETE USING (public.is_admin());

-- ============================================================
-- REALTIME: Enable for tables
-- ============================================================
-- Run in SQL Editor to enable realtime on required tables:
ALTER PUBLICATION supabase_realtime ADD TABLE public.votes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.candidates;
ALTER PUBLICATION supabase_realtime ADD TABLE public.elections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

