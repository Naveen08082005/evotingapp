-- ============================================================
-- E-VOTING SYSTEM — SEARCH RPC FUNCTIONS
-- ============================================================
-- Run in Supabase SQL Editor AFTER running schema.sql and rls_policies.sql
-- These functions provide safe parameterized search to prevent
-- query injection via user-supplied input.
-- ============================================================

-- ── Search candidates (parameterized, safe) ───────────────────────────────
CREATE OR REPLACE FUNCTION public.search_candidates(search_query TEXT)
RETURNS SETOF public.candidates
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Sanitize: limit length and strip leading/trailing whitespace
    search_query := TRIM(LEFT(search_query, 100));
    RETURN QUERY
        SELECT *
        FROM public.candidates
        WHERE
            (status = 'approved' OR public.is_admin())
            AND (
                name      ILIKE '%' || search_query || '%' OR
                position  ILIKE '%' || search_query || '%' OR
                department ILIKE '%' || search_query || '%'
            )
        ORDER BY name;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.search_candidates(TEXT) TO authenticated;

-- ── Search users (admin-only, parameterized) ──────────────────────────────
CREATE OR REPLACE FUNCTION public.search_users(search_query TEXT)
RETURNS SETOF public.users
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only admins may search users
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Permission denied';
    END IF;

    search_query := TRIM(LEFT(search_query, 100));
    RETURN QUERY
        SELECT *
        FROM public.users
        WHERE
            role = 'student'
            AND (
                full_name       ILIKE '%' || search_query || '%' OR
                register_number ILIKE '%' || search_query || '%' OR
                email           ILIKE '%' || search_query || '%'
            )
        ORDER BY full_name;
END;
$$;

-- Grant execute permission to authenticated users (function enforces admin check internally)
GRANT EXECUTE ON FUNCTION public.search_users(TEXT) TO authenticated;

-- ── Add is_global column to notifications (required for VF-16 fix) ────────
ALTER TABLE public.notifications
    ADD COLUMN IF NOT EXISTS is_global BOOLEAN NOT NULL DEFAULT FALSE;

-- Update existing global notifications (those with user_id IS NULL) to is_global = TRUE
UPDATE public.notifications
    SET is_global = TRUE
    WHERE user_id IS NULL;
