-- ============================================================
-- E-VOTING SYSTEM — SUPABASE POSTGRESQL SCHEMA
-- ============================================================
-- Run this entire file in the Supabase SQL Editor
-- Project: Secure Mobile-Based E-Voting System for College Elections
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE: admins
-- ============================================================
CREATE TABLE IF NOT EXISTS public.admins (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       TEXT NOT NULL UNIQUE,
    full_name   TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: users (students)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
    id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email             TEXT NOT NULL UNIQUE,
    full_name         TEXT NOT NULL,
    register_number   TEXT NOT NULL UNIQUE,
    mobile_number     TEXT NOT NULL,
    department        TEXT NOT NULL,
    year              TEXT,
    photo_url         TEXT,
    role              TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
    is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
    has_voted         BOOLEAN NOT NULL DEFAULT FALSE,
    voted_at          TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for users
CREATE INDEX IF NOT EXISTS idx_users_email            ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_register_number  ON public.users(register_number);
CREATE INDEX IF NOT EXISTS idx_users_department       ON public.users(department);
CREATE INDEX IF NOT EXISTS idx_users_has_voted        ON public.users(has_voted);

-- ============================================================
-- TABLE: elections
-- ============================================================
CREATE TABLE IF NOT EXISTS public.elections (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title                 TEXT NOT NULL,
    description           TEXT,
    status                TEXT NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'active', 'completed')),
    live_results_enabled  BOOLEAN NOT NULL DEFAULT FALSE,
    started_at            TIMESTAMPTZ,
    ended_at              TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for elections
CREATE INDEX IF NOT EXISTS idx_elections_status ON public.elections(status);

-- ============================================================
-- TABLE: candidates
-- ============================================================
CREATE TABLE IF NOT EXISTS public.candidates (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        TEXT NOT NULL,
    position    TEXT NOT NULL,
    department  TEXT NOT NULL,
    year        TEXT,
    manifesto   TEXT NOT NULL,
    photo_url   TEXT,
    status      TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'rejected')),
    vote_count  INTEGER NOT NULL DEFAULT 0,
    added_by    UUID REFERENCES public.admins(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for candidates
CREATE INDEX IF NOT EXISTS idx_candidates_status     ON public.candidates(status);
CREATE INDEX IF NOT EXISTS idx_candidates_position   ON public.candidates(position);
CREATE INDEX IF NOT EXISTS idx_candidates_vote_count ON public.candidates(vote_count DESC);

-- ============================================================
-- TABLE: votes
-- ============================================================
CREATE TABLE IF NOT EXISTS public.votes (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    candidate_id  UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    election_id   UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    voted_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Prevent duplicate votes per election
    CONSTRAINT unique_vote_per_election UNIQUE (user_id, election_id)
);

-- Indexes for votes
CREATE INDEX IF NOT EXISTS idx_votes_user_id      ON public.votes(user_id);
CREATE INDEX IF NOT EXISTS idx_votes_candidate_id ON public.votes(candidate_id);
CREATE INDEX IF NOT EXISTS idx_votes_election_id  ON public.votes(election_id);

-- ============================================================
-- TABLE: verification_settings
-- ============================================================
CREATE TABLE IF NOT EXISTS public.verification_settings (
    id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    require_register_number   BOOLEAN NOT NULL DEFAULT TRUE,
    require_full_name         BOOLEAN NOT NULL DEFAULT TRUE,
    require_mobile_number     BOOLEAN NOT NULL DEFAULT FALSE,
    require_department        BOOLEAN NOT NULL DEFAULT FALSE,
    require_email             BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- FUNCTION: increment_vote_count (RPC)
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_vote_count(candidate_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.candidates
    SET vote_count = vote_count + 1,
        updated_at = NOW()
    WHERE id = candidate_id;
END;
$$;

-- ============================================================
-- FUNCTION: auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Triggers for updated_at
CREATE OR REPLACE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_candidates_updated_at
    BEFORE UPDATE ON public.candidates
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_elections_updated_at
    BEFORE UPDATE ON public.elections
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_verification_settings_updated_at
    BEFORE UPDATE ON public.verification_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- SEED DATA: Default verification settings
-- ============================================================
INSERT INTO public.verification_settings (
    require_register_number,
    require_full_name,
    require_mobile_number,
    require_department,
    require_email
) VALUES (TRUE, TRUE, FALSE, FALSE, FALSE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- SAMPLE INSERT: Admin (run AFTER creating auth user)
-- Replace 'YOUR-AUTH-USER-UUID' with the actual UUID from Supabase Auth
-- ============================================================
/*
INSERT INTO public.admins (id, email, full_name)
VALUES (
    'YOUR-AUTH-USER-UUID',
    'admin@college.edu',
    'System Administrator'
);
*/

-- ============================================================
-- SAMPLE INSERT: Election
-- ============================================================
/*
INSERT INTO public.elections (title, description, status)
VALUES (
    'Student Council Election 2025',
    'Annual election for student council positions.',
    'pending'
);
*/

-- ============================================================
-- SAMPLE INSERT: Candidate
-- ============================================================
/*
INSERT INTO public.candidates (name, position, department, manifesto, status)
VALUES
    ('Arjun Kumar',   'President',  'Computer Science', 'I will improve campus facilities and student welfare programs.', 'approved'),
    ('Priya Sharma',  'Secretary',  'Electronics',      'Transparent governance and active student representation.',     'approved'),
    ('Rahul Mehta',   'Treasurer',  'Mechanical',       'Responsible management of student funds and budgets.',          'approved');
*/

-- ============================================================
-- TRIGGER: Automatically create student profile on Auth SignUp
-- ============================================================
-- This trigger runs with SECURITY DEFINER to bypass client RLS rules.
-- It extracts metadata submitted by the client during signup.
-- ============================================================
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
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'register_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'mobile_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'department', ''),
        NEW.raw_user_meta_data->>'year',
        'student',
        FALSE,
        FALSE
    )
    ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$;

-- Drop trigger if it exists and recreate it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title       TEXT NOT NULL,
    message     TEXT NOT NULL,
    user_id     UUID REFERENCES public.users(id) ON DELETE CASCADE, -- null means global/broadcast
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);


