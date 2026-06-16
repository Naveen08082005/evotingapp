# Security Checklist — College E-Voting System

This document outlines the security architecture and audit verification checklist for the College E-Voting System. Use this guide to ensure that student records, election settings, and cast votes are fully secured against tampering and unauthorized access.

---

## 1. Security Control Verification Matrix

Verify that each of the following security mechanisms is configured and functioning correctly before launching a live election.

### ✔ Row-Level Security (RLS) Enabled
- **Threat Mitigated**: Direct database queries bypassing backend logic to read/write voter records, elections, or candidates.
- **Implementation**: RLS is explicitly enabled on all tables in `supabase_setup.md` via `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`.
- **Audit Steps**:
  1. Open a REST client or API test tool (e.g., Postman).
  2. Attempt to make a `GET` or `POST` request to the `/rest/v1/votes` or `/rest/v1/admins` endpoints using the anon API key *without* an authorization header.
  3. Verify that the response returns empty (`[]`) or a `401 Unauthorized`/`403 Forbidden` status code.

### ✔ Authenticated Access Only
- **Threat Mitigated**: Anonymous users accessing voting screens, candidate profiles, or election configuration panels.
- **Implementation**:
  - Supabase client requires a valid JSON Web Token (JWT) on all client operations.
  - GetX middleware (`lib/routes/app_routes.dart` or page guards) intercepts unauthenticated routes and redirects users to the login screen.
- **Audit Steps**:
  1. Close/kill the app, delete app cache/local storage.
  2. Force-launch the app directly onto the `/user/dashboard` or `/admin/dashboard` route.
  3. Verify that the middleware intercepts the navigation and forces a redirect to `/login`.

### ✔ One Student, One Vote Enforcement
- **Threat Mitigated**: Double-voting or ballot stuffing by single voters.
- **Implementation**:
  - **Database Level**: A unique constraint on the `votes` table (`unique_vote_per_election UNIQUE (user_id, election_id)`) guarantees that a user cannot insert more than one vote per election.
  - **RLS Level**: The RLS insert policy for the `votes` table checks that the voter profile's `has_voted` column is `FALSE` and that they are verified (`is_verified = TRUE`).
  - **Transaction/RPC Level**: When a vote is successfully cast, the voter's profile `has_voted` is immediately toggled to `TRUE`.
- **Audit Steps**:
  1. Authenticate as a verified student.
  2. Cast a vote for a candidate in an active election.
  3. Attempt to invoke the vote insertion command a second time using the API or app interface.
  4. Verify that the database rejects the second insert with a duplicate key violation error (`23505`).

### ✔ Vote Tampering Prevention
- **Threat Mitigated**: Alteration of vote tallies or editing of historical votes.
- **Implementation**:
  - The `votes` table RLS policies allow students to only insert a new vote. The `UPDATE` and `DELETE` actions are entirely disallowed for all client-level roles (both students and admins).
  - The calculation of live results is performed using a database trigger/RPC (`increment_vote_count`) or raw aggregates, preventing clients from modifying the `vote_count` field of candidates directly.
- **Audit Steps**:
  1. Log in as an administrator or student.
  2. Select an existing record in the `votes` table.
  3. Attempt to execute an SQL `UPDATE` or `DELETE` statement on that row using the Supabase Javascript client or REST API.
  4. Verify that the server returns an RLS violation error or blocks the command (0 rows updated/deleted).

### ✔ Administrator Authorization & Role-Based Access (RBAC)
- **Threat Mitigated**: Compromised student accounts escalating privileges to perform admin tasks (e.g. creating candidates, stopping elections).
- **Implementation**:
  - Database schema contains an `admins` lookup table containing UUIDs of verified administrators.
  - RLS policies use the `public.is_admin()` SQL function to verify that the requesting user's `auth.uid()` exists in the `admins` table before allowing writes to `elections`, `candidates`, and `verification_settings`.
- **Audit Steps**:
  1. Log in as a standard verified student.
  2. Retrieve your session token.
  3. Attempt to make a `POST` request to `/rest/v1/elections` or `/rest/v1/candidates` to insert a new record.
  4. Verify that the server rejects the request with an RLS policy restriction error.

### ✔ Secure Local Storage
- **Threat Mitigated**: Extraction of access tokens or sensitive voter credentials from a lost or compromised mobile device.
- **Implementation**:
  - Access tokens, refresh tokens, and user credentials are saved in the device's secure enclave (iOS Keychain / Android Keystore) via `flutter_secure_storage` or securely encrypted wrappers in GetStorage.
  - App state variables stored in memory are cleared upon logout.
- **Audit Steps**:
  1. Compile and run the application on a rooted Android emulator or jailbroken iOS device.
  2. Inspect the sandbox directories (`/data/data/com.college.evoting/shared_prefs`).
  3. Verify that the authentication tokens are not stored in plaintext inside standard shared preferences XML files.

### ✔ Real-time Subscription Security
- **Threat Mitigated**: Eavesdropping on active voting data or intercepting notification broadcast feeds.
- **Implementation**:
  - WebSocket channels for Supabase Realtime follow the same RLS policies configured for HTTP requests.
  - Realtime subscriptions on the `votes` table are restricted. Even though clients listen to `votes` channels for updates, RLS guarantees that they only receive change notifications for events they are authorized to see.
- **Audit Steps**:
  1. Open a websocket client and attempt to connect to the realtime channel feed for `votes`.
  2. Authenticate as a standard student.
  3. Verify that you do not receive raw vote details of other students as they are cast.
