# Bugs Found: E-Voting Mobile Application

This document details all defects, functional issues, and security vulnerabilities identified during the assessment of the E-Voting mobile application.

---

## 🛠️ 1. Functional Defects

### BUG-F01: Admin Candidate Addition "Something went wrong" Failure
- **Severity:** **High** (Blocker for Admin operations)
- **Screen/Page:** [Add Candidate Screen](file:///d:/projects/evoting_app/lib/screens/admin/add_edit_candidate_screen.dart)
- **Reproduction Steps:**
  1. Login as an Administrator using `admin@demo.local` / `DemoAdmin#2026`.
  2. Tap the **Manage Candidates** button, then tap the floating Action Button (`+`).
  3. Enter candidate name, bio, and symbol.
  4. Select a profile picture from the device gallery.
  5. Tap the **Save** button.
- **Expected Result:** Candidate is successfully created in the Supabase database, the profile image uploads to the storage bucket, and the app redirects back to the Candidate List screen with a success snackbar.
- **Actual Result:** The application crashes and renders a red screen or generic snackbar: *"Something went wrong. Please try again."*.
- **Recommendation:** 
  1. Change the image parameter type from `File` (dart:io) to `XFile` (cross-platform compatible) to support both mobile platform file access and web buffers.
  2. Fix the foreign key constraint mismatch in Supabase: ensure that the `added_by` field uses a valid UUID registered in the `admins` table, and catch Postgres foreign key violations (`23503`) specifically to return a clean UI error message.
- **Status:** **FIXED** (Resolved by updates to storage service and exception helpers).

---

## 🔐 2. Security Vulnerabilities

### BUG-S01: Hardcoded Supabase API Credentials (VF-01)
- **Severity:** **Critical**
- **Screen/Page:** Main Database Connection / [supabase_constants.dart](file:///d:/projects/evoting_app/lib/core/constants/supabase_constants.dart)
- **Reproduction Steps:**
  1. Decompile the APK file (`app-debug.apk`) using toolsets like `apktool` or `jadx`.
  2. Search for the string `"supabase"` or look at the class corresponding to `SupabaseConstants`.
  3. Extract the plain-text `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- **Expected Result:** API credentials should not be exposed in the codebase or decompilable resources in plain text.
- **Actual Result:** Credentials were hardcoded as plain-text constants:
  ```dart
  static const String supabaseUrl = "https://xyczocswufelhpcrmjow.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey...";
  ```
- **Recommendation:** Retrieve configuration variables dynamically at build time using Flutter's `--dart-define` command-line compiler arguments, and check them in via `String.fromEnvironment`.
- **Status:** **FIXED**.

---

### BUG-S02: Client-Side Admin Role Verification Bypass (VF-21)
- **Severity:** **High**
- **Screen/Page:** [auth_repository.dart](file:///d:/projects/evoting_app/lib/repositories/auth_repository.dart)
- **Reproduction Steps:**
  1. Log in with a student email containing the string `"admin"` (e.g. `student.admin@college.edu`).
  2. The application checks `userId.contains('admin')` to grant administrative access.
  3. Observe that student is given dashboard access to Candidate Management and Election controls.
- **Expected Result:** Role assignment must be determined by a secure server-side relational lookup, not client-side string matches on the user ID.
- **Actual Result:** The login check used a loose string check on the ID:
  ```dart
  bool isAdmin = user.id.contains("admin");
  ```
- **Recommendation:** Update `AuthRepository` to query the database table `admins` specifically for the current `user.id`.
- **Status:** **FIXED**.

---

### BUG-S03: Missing Rate Limiting on Login Attempts (VF-11)
- **Severity:** **Medium**
- **Screen/Page:** [login_screen.dart](file:///d:/projects/evoting_app/lib/screens/auth/login_screen.dart) / [auth_controller.dart](file:///d:/projects/evoting_app/lib/controllers/auth_controller.dart)
- **Reproduction Steps:**
  1. Write an automated script that attempts to sign in repeatedly with random passwords.
  2. Observe that there are no delays or blocks triggered by the mobile client after multiple consecutive failures.
- **Expected Result:** Login interfaces should rate-limit attempts to prevent automated credential brute-forcing.
- **Actual Result:** Client permitted unlimited login requests without delay.
- **Recommendation:** Implement client-side rate-limiting using local timestamp checks (e.g., lock out the UI for 15 minutes after 5 consecutive failures) and configure Supabase server-side rate limits.
- **Status:** **FIXED**.

---

### BUG-S04: Weak Password Strength Enforcements (VF-06)
- **Severity:** **Medium**
- **Screen/Page:** [Register Screen](file:///d:/projects/evoting_app/lib/screens/auth/register_screen.dart) / [validators.dart](file:///d:/projects/evoting_app/lib/core/utils/validators.dart)
- **Reproduction Steps:**
  1. Open the Student Registration screen.
  2. Input a weak password such as `12345`.
  3. Tap **Register**.
- **Expected Result:** Registration form should reject passwords that do not meet length and complexity standards.
- **Actual Result:** Form validated passwords using only basic empty-checks, permitting weak passwords.
- **Recommendation:** Use a strong password validation regex enforcing at least 8 characters, with lowercase, uppercase, numerical digits, and special characters.
- **Status:** **FIXED**.

---

### BUG-S05: Exposed Hardcoded Credential Hints on Login Screen (VF-05)
- **Severity:** **Low**
- **Screen/Page:** [login_screen.dart](file:///d:/projects/evoting_app/lib/screens/auth/login_screen.dart)
- **Reproduction Steps:**
  1. Launch the application.
  2. Observe a visual card at the bottom containing plaintext emails and passwords for `admin@demo.local` and `student@demo.local`.
- **Expected Result:** Authentication credentials (even demo ones) should not be exposed in user-facing UI layouts in production packages.
- **Actual Result:** A hint widget displayed demo credentials.
- **Recommendation:** Remove the credential hint widget from the UI.
- **Status:** **FIXED**.

---

### BUG-S06: Missing Invalidation of Supabase Session on Logout (VF-15)
- **Severity:** **Medium**
- **Screen/Page:** [auth_controller.dart](file:///d:/projects/evoting_app/lib/controllers/auth_controller.dart)
- **Reproduction Steps:**
  1. Log in as a user.
  2. Tap **Logout**.
  3. Inspect local cache or try to execute a query using the cached token.
  4. The local token is not invalidated on the Supabase backend.
- **Expected Result:** Logging out must call the Supabase API to terminate the JWT session on the server.
- **Actual Result:** The app cleared local variables but did not invoke `Supabase.instance.client.auth.signOut()` when a demo flag was active.
- **Recommendation:** Always invoke `signOut()` on logout.
- **Status:** **FIXED**.

---

### BUG-S07: SQL Injection Vulnerability in Search Fields (VF-08 / VF-09)
- **Severity:** **High**
- **Screen/Page:** Candidate Search / User Search fields
- **Reproduction Steps:**
  1. Open the Candidate search box.
  2. Enter the string: `' UNION SELECT * FROM profiles; --`
- **Expected Result:** The search query is escaped safely.
- **Actual Result:** The app built dynamic queries using string interpolation (`"name = '${query}'"`), making it vulnerable to injection.
- **Recommendation:** Replace direct dynamic table SELECT queries with parameterized RPC functions.
- **Status:** **FIXED**.

---

### BUG-S08: Insecure File Uploads in Image Picker (VF-14)
- **Severity:** **High**
- **Screen/Page:** [storage_service.dart](file:///d:/projects/evoting_app/lib/services/storage_service.dart)
- **Reproduction Steps:**
  1. Select a file picker dialog for candidate symbols.
  2. Choose a malicious file, e.g. a script or `.exe` shell payload disguised as an image.
  3. Submit the form.
- **Expected Result:** Storage upload handler should validate the file extension, size, and file headers (magic bytes) to ensure only valid images are uploaded.
- **Actual Result:** System accepted files of any size or format and uploaded them directly to Supabase storage buckets.
- **Recommendation:** Enforce strict file extension checks, restrict size to 2MB, and check file signatures/headers.
- **Status:** **FIXED**.

---

### BUG-S09: Global Notifications RLS Bypass (VF-16)
- **Severity:** **Medium**
- **Screen/Page:** Supabase Database Policies / [rls_policies.sql](file:///d:/projects/evoting_app/supabase/rls_policies.sql)
- **Reproduction Steps:**
  1. Query notifications without credentials using REST API.
  2. Observe that notifications intended for private users are returned because the query filter checks `user_id IS NULL` incorrectly.
- **Expected Result:** Private notifications must only be readable by their owners.
- **Actual Result:** Database policy allowed reading any notification where `user_id` was null, which was used for global alerts but leaked unintended data.
- **Recommendation:** Change RLS check to target an explicit `is_global` boolean flag.
- **Status:** **FIXED**.

---

### BUG-S10: Exposure of PII in Demo Storage (VF-25)
- **Severity:** **Low**
- **Screen/Page:** [demo_store.dart](file:///d:/projects/evoting_app/lib/core/utils/demo_store.dart)
- **Reproduction Steps:**
  1. Inspect the source file `demo_store.dart`.
  2. Observe real student names, registration numbers, and departments hardcoded in the list.
- **Expected Result:** Test code and demo stores must only contain clearly fictional data to protect user privacy.
- **Actual Result:** Real names and details of students were exposed.
- **Recommendation:** Replace all occurrences with fictional placeholders (e.g. `Jane Doe`).
- **Status:** **FIXED**.
