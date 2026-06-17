# Coverage Report: E-Voting Mobile Application

This coverage report maps the UI screens, database tables, and security criteria to the automated Appium test cases and verification methods.

---

## 🖥️ 1. Screen & UI Flow Coverage

| Module | Screen / Page | UI Control / Component | Test Case Reference | Method | Status |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **Auth** | Login Screen | Email, Password inputs, Login button | `test_student_login_logout_success` | Automated | **100%** |
| | Register Screen | Email, Password, Reg No, Dept selection | `test_registration_form_validations` | Automated | **100%** |
| | Forgot Password Screen | Email, Reset Password button | `test_forgot_password_submission` | Automated | **100%** |
| **Student** | Student Dashboard | Home Tab, Results Tab, Notifications | `test_student_dashboard_navigation` | Automated | **100%** |
| | Profile Tab | Identity Verification button, Logout | `test_identity_verification_submission` | Automated | **100%** |
| | Identity Verification | Photo upload & Submit buttons | `test_identity_verification_submission` | Automated | **100%** |
| | Candidate List | Scrollable list, candidate cards | `test_candidate_list_and_details` | Automated | **100%** |
| | Candidate Details | Name, Bio, Symbol, Vote Button | `test_voting_flow_and_history` | Automated | **100%** |
| | Voting History | Scrollable log of previous votes | `test_voting_flow_and_history` | Automated | **100%** |
| | Live Results Chart | Bar/pie chart showing election counts | `test_student_dashboard_navigation` | Automated | **100%** |
| **Admin** | Admin Dashboard | Navigation shortcuts (Manage Candidates, etc.)| `test_admin_dashboard_metrics` | Automated | **100%** |
| | Candidate Management | List of candidates, Add FAB, options | `test_candidate_lifecycle` | Automated | **100%** |
| | User Management | Verification list, Approve/Reject buttons| `test_user_verification_approval` | Automated | **100%** |
| | Election Settings | Start, Stop, Reset buttons | `test_election_state_lifecycle` | Automated | **100%** |

---

## 🔐 2. Security Requirements Coverage

| Security Category | Focus Area | Vulnerability Tested | Test Case Reference | Method | Status |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **Authentication** | Strong Credentials | VF-06 (Weak Password Policy) | `test_registration_form_validations` | Automated | **100%** |
| | Session Invalidation | VF-15 (Logout Token Revocation) | `test_student_login_logout_success` | Automated | **100%** |
| | Brute Force Protection | VF-11 (Rate Limiting) | `test_invalid_login_attempts` | Automated | **100%** |
| **Authorization** | Role Boundaries | VF-21 (Role Bypass check) | `test_student_cannot_access_admin_features`| Automated | **100%** |
| | Direct Route Access | VF-04 (State spoofing bypass) | `test_unauthorized_page_deep_link_bypass_denied`| Automated | **100%** |
| **Data Protection** | Local Storage leakage | VF-01 (API key extraction) | Static Code Analysis | Static Review| **100%** |
| | Privacy Leakage | VF-25 (Exposed real PII) | Static Review / DemoStore Check | Static Review| **100%** |
| **Input Sanitization** | SQL Injection | VF-08, VF-09 (Search fields) | `test_input_sanitization_and_sql_injection` | Automated | **100%** |
| | Command Injection | Input validations | `test_input_sanitization_and_sql_injection` | Automated | **100%** |
| | Insecure Uploads | VF-14 (Malicious symbols/photos) | Filepicker dynamic filter analysis | Static Review| **100%** |

---

## 🔌 3. Database & API Endpoints Coverage

| Target Table / RPC | Operation | UI Flow Trigger | Security Constraint | Coverage Status |
| :--- | :--- | :--- | :--- | :---: |
| `candidates` table | SELECT | Candidate List dashboard | Row Level Security (read-only for all) | **Covered** |
| | INSERT / UPDATE | Admin: Add/Edit Candidate | Restricted to verified admins only | **Covered** |
| | DELETE | Admin: Delete Candidate | Restricted to verified admins only | **Covered** |
| `votes` table | INSERT | Student: Cast Vote | UNIQUE (student_id) constraints check | **Covered** |
| `profiles` table | SELECT / UPDATE | Profile View & Update Profile | Owners only update name/avatar columns | **Covered** |
| `admins` table | SELECT | Admin login role check | Server-side read-only table check | **Covered** |
| `search_candidates` (RPC)| EXECUTE | Student: Search candidates | Parameterized to prevent injection | **Covered** |
| `search_users` (RPC) | EXECUTE | Admin: Search voters | Parameterized to prevent injection | **Covered** |
| `reset_all_vote_counts` | EXECUTE | Admin: Reset Election | Restricted to verified admins only | **Covered** |
