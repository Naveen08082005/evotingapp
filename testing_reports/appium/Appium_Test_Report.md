# Appium Mobile Automation Test Report

This report details automated functional validations executed on Android emulator devices using Appium Page Objects and pytest.

| Test ID | Screen | Scenario | Expected Result | Actual Result | Status | Execution Date |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| TC-APP-01 | Register Screen | Student Registration valid submit | Registration successfully creates auth record and routes user to student dashboard. | Account created; user dashboard loads successfully. | **PASS** | 2026-06-18 |
| TC-APP-02 | Login Screen | Admin Login with valid credentials | Admin dashboard loads successfully exposing Manage Candidates and settings buttons. | Admin logged in and redirected to Admin panel dashboard. | **PASS** | 2026-06-18 |
| TC-APP-03 | Login Screen | Student Login with valid credentials | Student dashboard loads successfully exposing candidate list cards and voting status banners. | Student session established; Home tab loaded. | **PASS** | 2026-06-18 |
| TC-APP-04 | Profile Tab | User Session Logout | Clears session tokens, callssignOut() on Supabase client and redirects back to Login screen. | Logged out successfully; credentials fields visible again. | **PASS** | 2026-06-18 |
| TC-APP-05 | Election Settings | Create New Election (Pending state) | Election details saved successfully in database with status pending. | New pending election loaded in settings view. | **PASS** | 2026-06-18 |
| TC-APP-06 | Election Settings | Start and Activate Election | Broadcasts status change to active; UI updates in real-time. | Status switched to Active; student view displays active banner. | **PASS** | 2026-06-18 |
| TC-APP-07 | Candidate Management | Create Candidate profile and upload photo | Candidate added; profile image uploaded to candidate-photos storage bucket. | Candidate Jane Doe added and profile symbol uploaded successfully. | **PASS** | 2026-06-18 |
| TC-APP-08 | Candidate Management | Edit Candidate details | Edits saved to postgres table; updated details render on reload. | Candidate bio updated and persisted in DB. | **PASS** | 2026-06-18 |
| TC-APP-09 | Candidate Details | Cast Vote in active election | Vote increments count; voter status updates to Voted; vote button disabled. | Vote registered; student dashboard displays 'Voted' banner. | **PASS** | 2026-06-18 |
| TC-APP-10 | Voting Screen | Duplicate Vote Prevention Check | Blocks student from voting a second time; UNIQUE indexes verify block. | Vote button hidden; second database insert is rejected. | **PASS** | 2026-06-18 |
| TC-APP-11 | Results Tab | Live Results view chart updates | Bar chart displays live vote counts dynamically via Supabase Realtime. | Results graph loads and updates counts instantly. | **PASS** | 2026-06-18 |
| TC-APP-12 | Profile Tab | Update User Profile Name and Avatar | Edits saved in profiles table; updates restricted to allowlist columns. | User profile details updated successfully. | **PASS** | 2026-06-18 |
