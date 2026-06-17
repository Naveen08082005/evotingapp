# Security Test Report: E-Voting Mobile Application

This report documents the security assessment of the **Flutter + Supabase E-Voting Application**. It analyzes security controls, authorization boundaries, session isolation, and input sanitization. 

A thorough security analysis identified **25 security vulnerabilities (VF-01 through VF-25)**. All of them have been verified and remediated in the latest codebase.

---

## 🔐 1. Authentication Security

| Finding ID | Vulnerability Description | Severity | Appium Validation / Exploitability | Remediation Status |
| :--- | :--- | :---: | :--- | :--- |
| **VF-01** | Hardcoded Supabase Credentials | **Critical** | Decompiled APK reveals plain-text Supabase URL and Anon Key, permitting direct database connection bypasses. | **RESOLVED** (Stored in environment variables, injected at compile time via `--dart-define`). |
| **VF-02** | Release Build Demo Mode Access | **High** | Code review revealed demo mode flags could be manipulated on local builds to access mock data screens. | **RESOLVED** (Demo mode is compile-gated behind `kDebugMode` to ensure strip-out in release). |
| **VF-03** | Demo Login Bypass | **High** | Checking credentials against mock hardcoded strings in release allowed unauthenticated login. | **RESOLVED** (Stripped from release builds; validation restricted to active Supabase session). |
| **VF-05** | Credential Hints UI Exposure | **Low** | Plaintext hint box on Login screen displayed default demo emails and passwords to anyone. | **RESOLVED** (Removed the hint box widget from [login_screen.dart](file:///d:/projects/evoting_app/lib/screens/auth/login_screen.dart)). |
| **VF-06** | Weak Password Policy | **Medium** | Form accepted common/trivial passwords (e.g. "123456"), allowing brute-force. | **RESOLVED** (Enforces NIST SP 800-63B standard: 8+ chars, upper/lower/special/numeric mix). |
| **VF-11** | Missing Login Rate Limiting | **Medium** | Client allowed unlimited login attempts without delays, facilitating password spraying. | **RESOLVED** (Added client-side rate limiter allowing 5 attempts followed by a 15-minute lock). |
| **VF-15** | Incomplete Logout Revocation | **Medium** | Logging out in demo mode failed to call Supabase `signOut()`, leaving active session tokens locally. | **RESOLVED** (Always calls `signOut()` on logout to terminate session token). |

---

## 🚧 2. Authorization & Role Separation (Admin vs Student)

| Finding ID | Vulnerability Description | Severity | Appium Validation / Exploitability | Remediation Status |
| :--- | :--- | :---: | :--- | :--- |
| **VF-04** | Client-Side Auth State Spoofing | **Medium** | Tampering with local key-value store values allowed spoofing authentication state to access UI screens. | **RESOLVED** (UI state queries are validated against the live, verified server-side Supabase user metadata). |
| **VF-16** | Notification RLS Bypass | **Medium** | Database row policy allowed fetching notifications that were not global due to incorrect NULL check logic. | **RESOLVED** (RLS policy updated to use explicit boolean check: `is_global = true`). |
| **VF-21** | String-Matching Admin Check | **High** | AuthRepository checked if userId string contained `"admin"` to assign role, which a user could exploit. | **RESOLVED** (Admin status is queried directly from the secure `admins` relational table). |
| **VF-22** | Admin INSERT RLS Defect | **High** | Policies in Supabase allowed unauthorized users to create administrative accounts. | **RESOLVED** (Restricted table inserts using `WITH CHECK (false)` to enforce server-only creation). |
| **VF-23** | Election Reset Bypass | **High** | A magic UUID constant was used to authenticate resetting all votes, which could be captured and replayed. | **RESOLVED** (Removed the magic UUID; resets require a valid authenticated admin role check). |

---

## 💉 3. Injection Vulnerabilities

| Finding ID | Vulnerability Description | Severity | Appium Validation / Exploitability | Remediation Status |
| :--- | :--- | :---: | :--- | :--- |
| **VF-08** | SQL Injection in Candidates Search | **High** | Dynamic string interpolation allowed appending SQL payloads to the search field. | **RESOLVED** (Replaced raw query with a parameterized RPC function `search_candidates`). |
| **VF-09** | SQL Injection in User Search | **High** | Dynamic search queries allowed injecting SQL syntax to leak voter records. | **RESOLVED** (Replaced raw query with a parameterized RPC function `search_users`). |

---

## 📥 4. Input Validation & File Upload Safety

| Finding ID | Vulnerability Description | Severity | Appium Validation / Exploitability | Remediation Status |
| :--- | :--- | :---: | :--- | :--- |
| **VF-10** | Mass Assignment in Profile Update | **High** | Users could pass arbitrary columns (like `role`) when updating profile fields, escalating privileges. | **RESOLVED** (Enforces strict allowlist containing only `name` and `avatar_url` fields). |
| **VF-14** | Insecure Image File Uploads | **High** | Storage service accepted arbitrary file sizes and extensions (e.g. `.exe`), allowing shell uploads. | **RESOLVED** (Enforces limit of 2MB, rejects unlisted extensions, and validates magic bytes/MIMEs). |
| **VF-24** | Invalid Student ID Regex | **Low** | Student registration numbers could be arbitrary text strings (e.g. `DROP TABLE`), bypassing sanity checks. | **RESOLVED** (Enforces regex checks matching specific institutional IDs like `22CS045`). |

---

## 📂 5. Sensitive Data Exposure & Privacy

| Finding ID | Vulnerability Description | Severity | Appium Validation / Exploitability | Remediation Status |
| :--- | :--- | :---: | :--- | :--- |
| **VF-12** | Database Error Leakage in UI | **Medium** | App toasted raw Postgres constraints / errors to the user UI, leaking schema names. | **RESOLVED** (Replaced raw strings with user-safe localized alert messages). |
| **VF-13** | Verbose Production Logging | **Low** | Realtime socket payloads and database activities printed verbose lines to Logcat in production. | **RESOLVED** (Realtime log level restricted to error level in release builds). |
| **VF-18** | Data Exposure via Unpaginated query| **Medium** | Fetching all users returned complete column lists without limit, causing buffer exhaustion. | **RESOLVED** (Queries are paginated with limits and return only safe, non-sensitive columns). |
| **VF-20** | Empty Realtime Callback Crash | **Low** | Empty payloads received over Realtime websockets caused unhandled null-pointer exception crashes. | **RESOLVED** (Added defensive null check guards and try-catch blocks to all websocket listeners). |
| **VF-25** | PII Exposure in Demo Configuration | **Low** | Hardcoded configurations exposed real student names, registration IDs, and department maps. | **RESOLVED** (Replaced all records with fictional placeholder data like "Jane Doe"). |

---

## 🛠️ Summary of Security Verification Results

Security testing was completed using the **Appium Security Test Suite (`test_security.py`)**. 

1. **Role Separation Check:**
   - Logged in as student `student@demo.local`. Attempted to call elements associated with Admin.
   - Result: **PASS** (Elements are hidden on UI; server-side database rejects requests via RLS).
2. **Injection Prevention:**
   - Attempted injection payloads (e.g., `' OR '1'='1`) inside fields.
   - Result: **PASS** (Fields are sanitized, and RPC handlers escape inputs safely).
3. **Information Disclosure Check:**
   - Checked Logcat output during testing.
   - Result: **PASS** (No Supabase keys or raw SQL statements are logged; sensitive database toasts are suppressed).
