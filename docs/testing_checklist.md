# Testing Checklist — College E-Voting System

This document provides a comprehensive Quality Assurance (QA) testing checklist for the College E-Voting System. Use this checklist to verify application logic, state transitions, security constraints, and UI flows before deploying to production.

---

## 1. Authentication & Session Management

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **AUTH-01** | Student Login | Input correct email and password. Click "Login". | User dashboard loads successfully. Local session is persisted. | `[ ]` |
| **AUTH-02** | Invalid Login Credentials | Input incorrect email or wrong password. Click "Login". | Error toast/popup displays. Red validation borders appear. | `[ ]` |
| **AUTH-03** | Form Input Validation | Leave email/password empty, or enter invalid email format. | "Invalid email" or "Password too short" validator messages appear. | `[ ]` |
| **AUTH-04** | Forgot Password Reset | Input registered email in Forgot Password screen, click "Reset". | Password reset email notification is sent from Supabase. | `[ ]` |
| **AUTH-05** | Session Persistence | Log in, close the app completely, and reopen the app. | Splash screen detects active session and bypasses login screen. | `[ ]` |
| **AUTH-06** | Logout Process | Click "Logout" in settings/profile or admin drawer. | Session is cleared from local storage. Redirected to Login. | `[ ]` |

---

## 2. Student Registration & Onboarding

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **REG-01** | Student Registration | Register with a unique registration number, photo, and details. | Account is created. Verification email sent. Profile saved. | `[ ]` |
| **REG-02** | Duplicate Reg Number | Try registering with an already existing register number. | DB unique constraint catches error. App displays warning. | `[ ]` |
| **REG-03** | Photo Upload | Upload an image from gallery or capture from camera on signup. | Image is uploaded to `avatars` bucket and visible in profile. | `[ ]` |
| **REG-04** | Email Verification Lock | Log in with a newly registered account *before* confirming email. | App displays "Please check your inbox to verify your email". | `[ ]` |

---

## 3. Voter Profile Verification (Admin & Student)

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **VER-01** | Unverified Dashboard Lock | Log in as verified = FALSE. Try to enter the voting screen. | Voting access is blocked. "Profile verification pending" banner. | `[ ]` |
| **VER-02** | Admin Approval | Log in as Admin. Navigate to User Management. Approve student. | Student's `is_verified` status is updated to TRUE in the database. | `[ ]` |
| **VER-03** | Verified Profile Access | Log in as student after admin approval. Enter voting screen. | Student is allowed to view ballot and cast votes. | `[ ]` |

---

## 4. Voting Flow (One Student, One Vote)

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **VOTE-01** | Cast a Successful Vote | Select candidate, click "Cast Vote", confirm selection in Dialog. | Vote cast message shown. Candidate vote count increments. | `[ ]` |
| **VOTE-02** | Double Voting Block | Attempt to cast another vote in the same election. | Blocked at UI level. RLS policy blocks at Database level. | `[ ]` |
| **VOTE-03** | Dashboard Status Update | Complete voting, return to User Dashboard. | The voting button is disabled or updated to "Vote Cast". | `[ ]` |
| **VOTE-04** | Voting History logs | Navigate to Voting History. | The voter's casted vote record (timestamp and election) is visible. | `[ ]` |

---

## 5. Real-time Results & Charts

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **RES-01** | Live Results Toggle | Verify live results visibility when setting is ON vs OFF. | Results shown to students only when `live_results_enabled` is TRUE. | `[ ]` |
| **RES-02** | Real-time Vote Count Updates | Cast vote on Device A. Observe Live Results graph on Device B. | The vote bar/pie chart increments instantly without manual refresh. | `[ ]` |
| **RES-03** | Candidate Vote Count Sync | Verify DB `vote_count` matches the actual sum of entries in `votes`. | Strict check: `SELECT COUNT(*) FROM votes` matches candidate votes. | `[ ]` |

---

## 6. Notifications & Broadcasts

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **NOT-01** | Global Admin Broadcast | Log in as Admin. Send notification: "Elections have started!". | Broadcast is pushed to all students instantly. | `[ ]` |
| **NOT-02** | Real-time Banner Popup | Have app open on student device. Pushes admin broadcast. | An in-app alert dialog or floating banner pops up immediately. | `[ ]` |
| **NOT-03** | Mark Notification as Read| Go to Notifications page, click a notification card. | Status updates. Count badge decrement. Marked `is_read` in DB. | `[ ]` |

---

## 7. Administrator Dashboards & Controls

| Test Case ID | Test Scenario | Steps to Verify | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :---: |
| **ADM-01** | Create Election | Click "Create Election", insert title and details. | Election created in state `pending`. Displayed in admin panel. | `[ ]` |
| **ADM-02** | Start Election | Select a pending election, click "Start Election". | Election status updates to `active`. Students can now see ballot. | `[ ]` |
| **ADM-03** | Stop Election | Select an active election, click "Stop Election". | Election status updates to `completed`. Voting is closed. | `[ ]` |
| **ADM-04** | Manage Candidates (CRUD) | Add new candidate with photo. Edit bio. Delete test candidate. | Photo uploads to `candidate-photos`. Candidate details synced. | `[ ]` |
| **ADM-05** | Unauthorized Student Access | Log in as a student, attempt to route to `/admin/dashboard`. | GetX routing middleware intercepts request and redirects to login. | `[ ]` |
