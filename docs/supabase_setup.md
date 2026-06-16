# Supabase Setup Guide — College E-Voting System

This guide walks you through setting up and configuring the Supabase backend for the College E-Voting System. It covers project creation, authentication settings, database execution, storage buckets, Row-Level Security (RLS) configuration, realtime subscriptions, and admin provisioning.

---

## 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign in or sign up.
2. Click **New Project** and choose/create an organization.
3. Configure the project parameters:
   - **Name**: e.g., `College E-Voting System`
   - **Database Password**: Set a strong password (record it somewhere secure).
   - **Region**: Choose a region closest to your target campus user base.
   - **Pricing Plan**: Free tier is sufficient for testing; consider Pro tier for production elections with high concurrent voting loads.
4. Click **Create new project** and wait for the database provisioning to complete (typically takes 1-2 minutes).

---

## 2. Authentication Setup

1. In the Supabase Dashboard sidebar, navigate to **Project Settings** -> **API**.
2. Retrieve the **Project URL** and the **anon public API Key**. Save these values for your `.env` configuration.
3. Go to **Authentication** -> **Providers** -> **Email**:
   - Ensure the **Email Provider** toggle is turned **ON**.
   - Ensure **Confirm Email** is enabled (so students must confirm their emails before accessing the platform).
   - Set **Secure email change** to **ON**.
4. Set up an SMTP server under **Authentication** -> **SMTP** (Recommended for Production release to prevent email delivery rate limits or spam filtering).

---

## 3. Email Verification Setup

Under **Authentication** -> **Email Templates**, customize the **Confirm Signup** template to match your college branding.
- **Subject**: `[College Elections] Verify your email address`
- **Body Content**:
  ```html
  <h2>Verify your College E-Voting Registration</h2>
  <p>Thank you for registering for the College E-Voting System. Please click the link below to verify your email address and activate your voter profile:</p>
  <p><a href="{{ .ConfirmationURL }}">Verify My Account</a></p>
  <p>If you did not request this registration, please ignore this email.</p>
  ```

---

## 4. Database Schema Execution

Go to the **SQL Editor** in the Supabase Dashboard, click **New Query**, paste the entire SQL block below, and click **Run**:

```sql
-- ============================================================
-- E-VOTING SYSTEM — DATABASE INITIALIZATION SCRIPT
-- ============================================================
-- Targets: Supabase PostgreSQL
-- Features: 
--  1. Auto-sync user metadata on signup
--  2. Strict One-Student-One-Vote constraints
--  3. SECURE Row-Level Security (RLS) policies
--  4. Realtime subscription replication
-- ============================================================

-- 0. ENABLE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. TABLES DEFINITIONS
-- ============================================================

-- A. ADMINS TABLE
CREATE TABLE IF NOT EXISTS public.admins (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       TEXT NOT NULL UNIQUE,
    full_name   TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- B. USERS TABLE (STUDENTS)
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

-- C. ELECTIONS TABLE
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

-- D. CANDIDATES TABLE
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

-- E. VOTES TABLE (MAPPED TO ELECTIONS AND STUDENTS)
CREATE TABLE IF NOT EXISTS public.votes (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    candidate_id  UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    election_id   UUID NOT NULL REFERENCES public.elections(id) ON DELETE CASCADE,
    voted_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Enforcement: One Student One Vote per Election
    CONSTRAINT unique_vote_per_election UNIQUE (user_id, election_id)
);

-- F. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title       TEXT NOT NULL,
    message     TEXT NOT NULL,
    user_id     UUID REFERENCES public.users(id) ON DELETE CASCADE, -- NULL indicates global broadcast alert
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- G. VERIFICATION SETTINGS TABLE
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
-- 2. INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_users_email              ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_register_number    ON public.users(register_number);
CREATE INDEX IF NOT EXISTS idx_users_department         ON public.users(department);
CREATE INDEX IF NOT EXISTS idx_users_has_voted          ON public.users(has_voted);

CREATE INDEX IF NOT EXISTS idx_elections_status         ON public.elections(status);

CREATE INDEX IF NOT EXISTS idx_candidates_status       ON public.candidates(status);
CREATE INDEX IF NOT EXISTS idx_candidates_position     ON public.candidates(position);
CREATE INDEX IF NOT EXISTS idx_candidates_vote_count   ON public.candidates(vote_count DESC);

CREATE INDEX IF NOT EXISTS idx_votes_user_id            ON public.votes(user_id);
CREATE INDEX IF NOT EXISTS idx_votes_candidate_id       ON public.votes(candidate_id);
CREATE INDEX IF NOT EXISTS idx_votes_election_id        ON public.votes(election_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id    ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- ============================================================
-- 3. FUNCTIONS & PROCEDURAL TRIGGERS
-- ============================================================

-- A. AUTOMATIC TIMESTAMP UPDATES
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

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

-- B. VOTE INCREMENT TRANSACTION (RPC)
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

-- C. AUTO-POPULATE STUDENT PROFILE TRIGGER ON AUTH SIGNUP
-- This function runs with SECURITY DEFINER to bypass client RLS rules.
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================
ALTER TABLE public.admins                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.elections             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidates            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications         ENABLE ROW LEVEL SECURITY;

-- Helper check function for RLS
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

-- A. ADMINS TABLE POLICIES
CREATE POLICY "admins_select_own" ON public.admins FOR SELECT USING (id = auth.uid());
CREATE POLICY "admins_insert_service" ON public.admins FOR INSERT WITH CHECK (public.is_admin());

-- B. USERS TABLE POLICIES
CREATE POLICY "users_select_admin" ON public.users FOR SELECT USING (public.is_admin());
CREATE POLICY "users_select_own"   ON public.users FOR SELECT USING (id = auth.uid());
CREATE POLICY "users_insert_own"   ON public.users FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "users_update_own"   ON public.users FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "users_update_admin" ON public.users FOR UPDATE USING (public.is_admin());

-- C. ELECTIONS TABLE POLICIES
CREATE POLICY "elections_select_authenticated" ON public.elections FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "elections_insert_admin"         ON public.elections FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "elections_update_admin"         ON public.elections FOR UPDATE USING (public.is_admin());
CREATE POLICY "elections_delete_admin"         ON public.elections FOR DELETE USING (public.is_admin());

-- D. CANDIDATES TABLE POLICIES
CREATE POLICY "candidates_select_approved" ON public.candidates FOR SELECT USING (status = 'approved' OR public.is_admin());
CREATE POLICY "candidates_insert_admin"    ON public.candidates FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "candidates_update_admin"    ON public.candidates FOR UPDATE USING (public.is_admin());
CREATE POLICY "candidates_delete_admin"    ON public.candidates FOR DELETE USING (public.is_admin());

-- E. VOTES TABLE POLICIES
CREATE POLICY "votes_select_admin" ON public.votes FOR SELECT USING (public.is_admin());
CREATE POLICY "votes_select_own"   ON public.votes FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "votes_insert_own"   ON public.votes FOR INSERT WITH CHECK (
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
CREATE POLICY "votes_delete_admin" ON public.votes FOR DELETE USING (public.is_admin());

-- F. NOTIFICATIONS TABLE POLICIES
CREATE POLICY "notifications_select_admin" ON public.notifications FOR SELECT USING (public.is_admin());
CREATE POLICY "notifications_select_user"  ON public.notifications FOR SELECT USING (user_id = auth.uid() OR user_id IS NULL);
CREATE POLICY "notifications_insert_admin" ON public.notifications FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "notifications_update_user"  ON public.notifications FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "notifications_delete_admin" ON public.notifications FOR DELETE USING (public.is_admin());

-- G. VERIFICATION SETTINGS POLICIES
CREATE POLICY "verification_settings_select"       ON public.verification_settings FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "verification_settings_update_admin" ON public.verification_settings FOR UPDATE USING (public.is_admin());
CREATE POLICY "verification_settings_insert_admin" ON public.verification_settings FOR INSERT WITH CHECK (public.is_admin());

-- ============================================================
-- 5. REALTIME REPLICATION CONFIGURATION
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.votes;
ALTER PUBLICATION supabase_realtime ADD TABLE public.candidates;
ALTER PUBLICATION supabase_realtime ADD TABLE public.elections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ============================================================
-- 6. DEFAULT SEED DATA
-- ============================================================
INSERT INTO public.verification_settings (
    require_register_number,
    require_full_name,
    require_mobile_number,
    require_department,
    require_email
) VALUES (TRUE, TRUE, FALSE, FALSE, FALSE)
ON CONFLICT DO NOTHING;
```

---

## 5. Storage Buckets Creation

The application requires two storage buckets to store images for profiles and candidates.

1. Navigate to **Storage** in the sidebar.
2. Click **New Bucket**:
   - **Bucket Name**: `avatars`
   - **Public Bucket**: **ON** (Enabled - allows students and admins to fetch images via direct URLs)
   - Click **Save**.
3. Click **New Bucket** again:
   - **Bucket Name**: `candidate-photos`
   - **Public Bucket**: **ON** (Enabled)
   - Click **Save**.
4. Set up security policies for Storage:
   - Go to **Storage** -> **Policies** (or edit from Database RLS policies).
   - For **avatars**:
     - Allow `SELECT` for authenticated users (`auth.uid() IS NOT NULL`).
     - Allow `INSERT` and `UPDATE` for owners (`auth.uid() = owner`).
   - For **candidate-photos**:
     - Allow `SELECT` for authenticated users (`auth.uid() IS NOT NULL`).
     - Allow `INSERT`, `UPDATE`, and `DELETE` for administrators only (`public.is_admin()`).

---

## 6. Row-Level Security (RLS)

RLS is enabled automatically for all tables via the database script. It enforces:
- Students can only view their own user profile, register their vote, view global notifications, and read active approved candidate data.
- Admins can manage elections, candidates, notifications, verification settings, and read/update all students.
- Only administrators can query the full collection of raw votes.

---

## 7. Realtime Configuration

Replication of change feeds is enabled for the tables: `votes`, `candidates`, `elections`, and `notifications` via the `ALTER PUBLICATION supabase_realtime ADD TABLE` statements in the SQL block. This enables live charts, results updates, and broadcast message popups in the application using WebSockets.

---

## 8. Admin Account Creation

To provision the first admin user, follow these steps:

1. **Sign Up via App**:
   Register a normal account using the mobile app or via Supabase Dashboard (**Authentication** -> **Users** -> **Add User**). For example: `admin@college.edu`.

2. **Retrieve the User UUID**:
   Go to the Supabase **Authentication** panel, select the user, and copy their **User ID** (e.g., `d6c1f1ad-cc99-4d6d-9799-a6e542cc7711`).

3. **Insert Admin Records (SQL Editor)**:
   Run the following query in the SQL Editor to promote the user to Admin status:
   ```sql
   -- Insert the UUID into the admins list
   INSERT INTO public.admins (id, email, full_name)
   VALUES (
     'd6c1f1ad-cc99-4d6d-9799-a6e542cc7711', -- Paste your user ID here
     'admin@college.edu',                    -- Paste your admin email
     'Main Election Administrator'           -- Admin name
   );

   -- Update role inside users profile
   UPDATE public.users
   SET role = 'admin', 
       is_verified = TRUE                  -- Admins are pre-verified
   WHERE id = 'd6c1f1ad-cc99-4d6d-9799-a6e542cc7711';
   ```

---

## 9. Security Best Practices

- **Never Disable RLS**: Ensure Row-Level Security remains active on all tables.
- **Limit Service Role usage**: The `service_role` key bypasses all RLS policies. Keep this key out of the Flutter client codebase. Only use it in secure serverless functions or backends if necessary.
- **Enable SSL Verification**: Force SSL connections in database parameters.
- **API Key restriction**: If deploying web/mobile clients, secure CORS settings in Supabase to reject connections from unauthorized web origins (if publishing a web companion).
- **Enforce Email Domain Filters**: If your college uses Google Workspace or custom mailboxes, restrict authentication signup domains to `@yourcollege.edu` inside **Authentication** -> **Providers** -> **Email Settings**.
