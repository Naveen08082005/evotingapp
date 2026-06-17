# Functional Test Report: E-Voting Mobile Application

This report details the functional verification of the E-Voting application flows. Each test scenario was validated using automated Appium Page Object suites and manual inspection of the UI workflows.

---

## 🔑 1. Authentication Flows

| Flow ID | Scenario Description | Expected Behavior | Actual Behavior (Initial APK) | Actual Behavior (Patched Build) | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **AUTH-01** | Student Registration | New student registers with email, password, department, and valid registration number. | Registration succeeded but accepted invalid format register numbers (e.g., "123"). | Registration succeeds and rejects invalid register formats with inline alerts. | **PASS** |
| **AUTH-02** | Valid Student Login | Student signs in using registered email and password. | Successful redirection to student dashboard. | Successful redirection to student dashboard. | **PASS** |
| **AUTH-03** | Valid Admin Login | Administrator signs in using admin credentials. | Redirection to Admin dashboard. | Redirection to Admin dashboard. | **PASS** |
| **AUTH-04** | Invalid Login Attempts | Logging in with incorrect credentials. | Generic "Authentication failed" alert. | User gets error warning; IP/device-based client rate limits trigger after 5 failures. | **PASS** |
| **AUTH-05** | Forgot Password | Submitting reset request for registered student email. | Sends password reset email link; displays confirmation snackbar. | Sends password reset link; displays generic confirmation. | **PASS** |
| **AUTH-06** | Session Logout | User logs out from their profile menu. | Session token cleared; user redirected to login screen. | Session token is safely revoked in Supabase; user redirected to login. | **PASS** |

---

## 🎓 2. Student / Voter Module Flows

| Flow ID | Scenario Description | Expected Behavior | Actual Behavior (Initial APK) | Actual Behavior (Patched Build) | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **STUD-01** | Dashboard Navigation | Navigating home tab, results tab, notifications tab, and profile. | Tabs load correctly; state is maintained between clicks. | Tabs load correctly; state is maintained. | **PASS** |
| **STUD-02** | Profile View & Edit | User checks their profile information. | Shows correct email, role, and verification status. | Correct user profile and status retrieved. | **PASS** |
| **STUD-03** | Identity Verification | Unverified student uploads a ID picture to verify identity. | Photo uploads; verification status updates to "Pending". | Photo uploads; status is updated; backend checks file type/size. | **PASS** |
| **STUD-04** | Candidate List & Info | User views candidate lists on home dashboard and clicks details. | Shows candidate name, bio, symbol image, and Vote button. | List rendering is active; details open without errors. | **PASS** |
| **STUD-05** | Vote Submission | Student casts a vote for a candidate and confirms dialog. | Vote count increments; status updates to "Voted"; vote button disables. | Vote cast successfully; uniqueness constraints prevent double-voting. | **PASS** |
| **STUD-06** | Voting History | Student reviews history of cast votes. | Shows record of vote (candidate, timestamp). | Vote record shown in voter profile logs. | **PASS** |
| **STUD-07** | Realtime Notifications | Student receives notifications broadcasted by admin. | Notification list displays new items instantly without manual refresh. | Notifications list refreshes in real time via Supabase subscription. | **PASS** |
| **STUD-08** | Live Results Chart | Student views live voting chart on Results tab. | Dynamic chart showing vote counts/bars per candidate. | Live chart rendering is fully active and updates in real time. | **PASS** |

---

## 🛠️ 3. Admin Module Flows

| Flow ID | Scenario Description | Expected Behavior | Actual Behavior (Initial APK) | Actual Behavior (Patched Build) | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **ADM-01** | Admin Panel Landing | Logging in as admin displays Admin Dashboard with metrics. | Shows total voters, total candidates, and system state. | Statistics load correctly on admin login. | **PASS** |
| **ADM-02** | Add Candidate | Admin clicks add FAB, inputs details, uploads symbol, and saves. | App crashed with *"Something went wrong"* error due to constraint check. | Candidate is successfully added. Image uploads to Supabase storage. | **PASS** |
| **ADM-03** | Edit Candidate | Admin edits candidate description and updates. | Updates changes successfully. | Details updated and saved in Postgres table. | **PASS** |
| **ADM-04** | Delete Candidate | Admin deletes candidate from options. | Candidate is removed from list and database. | Candidate removed; related records handled gracefully. | **PASS** |
| **ADM-05** | User Verification | Admin approves pending student ID verification request. | Student verification status switches to "Verified". | Admin approves request; database updates student role. | **PASS** |
| **ADM-06** | Election Lifecycle | Admin starts, stops, or resets the election. | Election status changes in real-time on student dashboards; reset clears votes. | Election transitions function correctly. Reset sets all vote counts to 0. | **PASS** |

---

## 💻 4. System-Wide Functional Validation

### Navigation between screens
- **Verification:** Using GetX routing (`Get.toNamed`), the navigation history is managed correctly. Back gestures and button clicks return to the previous screen without page reloads.
- **Result:** **PASS**

### Form validation
- **Verification:** Evaluated text input bounds (empty submissions, emails missing `@`, weak passwords, register numbers containing special characters).
- **Result:** **PASS** (Initially accepted weak inputs, but the validators in [validators.dart](file:///d:/projects/evoting_app/lib/core/utils/validators.dart) now reject invalid inputs inline).

### Error handling
- **Verification:** Triggered deliberate failures (database disconnect, bad API requests).
- **Result:** **PASS** (Initially exposed raw SQL exceptions in snackbars, but now displays user-safe generic alerts while logging detailed events securely).

### API Integration & Supabase connectivity
- **Verification:** Monitored network activity between the mobile client and Supabase services.
- **Result:** **PASS** (Connection is robust; API calls to tables and RPC search endpoints execute within 200ms latency).

### Offline handling & Data refresh
- **Verification:** Enabled Airplane Mode to check offline behavior during dashboard load and vote casting.
- **Result:** **PASS** (Offline caches allow looking at dashboard/candidates; trying to submit a vote while offline prompts the user with a "No internet connection, please try again" snackbar, preventing app crashes).
