# Visual Evidence & Screenshots Directory

This directory contains screenshots captured during functional testing and security assessments, showcasing both initial vulnerabilities/defects and post-mitigation success states.

---

## 📸 Index of Screenshots

### 🛡️ Security Vulnerability Visualizations

1. **Vulnerability VF-05 (Credential UI Exposure):**
   - **File:** [login_screen_visible_1781411441653.png](file:///d:/projects/evoting_app/Appium_Test_Results/Failed_Test_Screenshots/login_screen_visible_1781411441653.png)
   - **Details:** Shows the initial login screen rendering a plaintext card with demo emails and passwords directly to users. This has been removed in the patched build.

2. **Database Error Info Disclosure (VF-12):**
   - **File:** [add_candidate_result_1781411838015.png](file:///d:/projects/evoting_app/Appium_Test_Results/Failed_Test_Screenshots/add_candidate_result_1781411838015.png)
   - **Details:** Captured during a candidate creation failure. Shows the database constraint checks and internal table structures being exposed directly in the UI.

---

### ⚙️ Functional Test Visualizations

1. **Successful Candidate Creation (BUG-F01 Mitigation):**
   - **File:** [candidate_added_successfully_1781412155375.png](file:///d:/projects/evoting_app/Appium_Test_Results/Failed_Test_Screenshots/candidate_added_successfully_1781412155375.png)
   - **Details:** Confirms that after upgrading parameter handling to `XFile` and modifying backend logic, adding candidates completes with a success dialog rather than crashing.

2. **Candidate List Navigation:**
   - **File:** [candidates_list_scrolled_1781420542541.png](file:///d:/projects/evoting_app/Appium_Test_Results/Failed_Test_Screenshots/candidates_list_scrolled_1781420542541.png)
   - **Details:** Showcases the candidate management scrolling list interface loading correctly for administrators.

3. **Dashboard Load State:**
   - **File:** [initial_page_load_1781411427774.png](file:///d:/projects/evoting_app/Appium_Test_Results/Failed_Test_Screenshots/initial_page_load_1781411427774.png)
   - **Details:** Visual check of the web/mobile initialization splash sequence loading without errors.
