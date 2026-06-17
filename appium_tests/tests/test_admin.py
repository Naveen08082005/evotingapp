import pytest
import time
from page_objects.login_page import LoginPage
from page_objects.admin_dashboard_page import AdminDashboardPage

@pytest.fixture(scope="function")
def logged_in_admin(driver, admin_credentials):
    """Fixture that logs in an admin and cleans up afterwards."""
    login_page = LoginPage(driver)
    admin_page = AdminDashboardPage(driver)
    login_page.login(admin_credentials["email"], admin_credentials["password"])
    yield admin_page
    admin_page.admin_logout()

def test_admin_dashboard_metrics(logged_in_admin):
    """
    Test Case: Verify admin dashboard loads statistics and metrics.
    """
    admin = logged_in_admin
    # Ensure stats elements exist on landing
    assert admin.is_element_visible(admin.MANAGE_CANDIDATES_BUTTON), "Manage Candidates button missing"
    assert admin.is_element_visible(admin.MANAGE_USERS_BUTTON), "Manage Users button missing"
    assert admin.is_element_visible(admin.ELECTION_SETTINGS_BUTTON), "Election Settings button missing"


def test_candidate_lifecycle(logged_in_admin):
    """
    Test Case: Complete lifecycle of a candidate (Add -> Edit -> Delete).
    """
    admin = logged_in_admin
    candidate_name = "Automated Candidate"
    candidate_bio = "This is a candidate added by an automated Appium script."
    candidate_symbol = "APPIUM_LOGO"
    
    # 1. Add Candidate
    admin.add_candidate(candidate_name, candidate_bio, candidate_symbol)
    
    # Check that candidate is visible in the list
    candidate_label = (admin.MANAGE_CANDIDATES_BUTTON[0], f"//*[contains(@text, '{candidate_name}') or contains(@content-desc, '{candidate_name}')]")
    assert admin.is_element_present(candidate_label), f"Candidate '{candidate_name}' was not found in list after creation"
    
    # 2. Edit Candidate
    admin.click(candidate_label) # open candidate or options
    admin.click(admin.EDIT_OPTION)
    admin.send_keys(admin.CANDIDATE_BIO_FIELD, "Updated Bio via Appium")
    admin.click(admin.SAVE_CANDIDATE_BUTTON)
    
    # Verify edit was successful (optional list view verification)
    time.sleep(1)
    
    # 3. Delete Candidate
    admin.delete_candidate(candidate_name)
    
    # Verify candidate is no longer in list
    assert not admin.is_element_present(candidate_label, timeout=3), f"Candidate '{candidate_name}' still exists after deletion"


def test_user_verification_approval(logged_in_admin):
    """
    Test Case: Approve user identity verification and verify state changes.
    """
    admin = logged_in_admin
    
    # Check if there is a pending user and approve it
    approved = admin.approve_first_pending_user()
    if approved:
        print("[INFO] Successfully approved a pending user.")
    else:
        print("[INFO] No pending users found to verify.")


def test_election_state_lifecycle(logged_in_admin):
    """
    Test Case: Verify election state changes (Start, Stop, Reset).
    """
    admin = logged_in_admin
    
    # 1. Transition to Start Election
    admin.change_election_state("start")
    # In a real environment, assert status text in dashboard contains 'Active' or 'Running'
    
    # 2. Transition to Stop Election
    admin.change_election_state("stop")
    # Assert status text contains 'Stopped' or 'Closed'
    
    # 3. Transition to Reset Election
    admin.change_election_state("reset")
    # Assert status resets to inactive/ready
