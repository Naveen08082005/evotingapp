-- Migration: Performance Indexes and One User One Vote Constraints
-- Date: 2026-07-22

-- 1. Create Index on users email, register_number, and role
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_register_number ON public.users(register_number);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- 2. Create Index on candidates position and election_id
CREATE INDEX IF NOT EXISTS idx_candidates_election_id ON public.candidates(election_id);
CREATE INDEX IF NOT EXISTS idx_candidates_position ON public.candidates(position);

-- 3. Unique Constraint for One User One Vote Validation
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_per_election ON public.votes(user_id, election_id);
CREATE INDEX IF NOT EXISTS idx_votes_candidate_id ON public.votes(candidate_id);

-- 4. Enable Row Level Security (RLS) on votes table
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can insert vote" ON public.votes;
CREATE POLICY "Authenticated users can insert vote" ON public.votes 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can read votes" ON public.votes;
CREATE POLICY "Users can read votes" ON public.votes 
  FOR SELECT USING (auth.uid() = user_id OR is_admin());
