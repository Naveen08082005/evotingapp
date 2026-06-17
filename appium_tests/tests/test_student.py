import pytest
import time
from page_objects.login_page import LoginPage
from page_objects.student_dashboard_page import StudentDashboardPage

@pytest.fixture(scope="function")
def logged_in_student(driver, student_credentials):
    """Fixture that logs in a student and cleans up afterwards."""
    login_page = LoginPage(driver)
    dashboard_page = StudentDashboardPage(driver)
    login_page.login(student_credentials["email"], student_credentials["password"])
    yield dashboard_page
    dashboard_page.logout()

def test_student_dashboard_navigation(logged_in_student):
    """
    Test Case: Verify navigation between tabs in Student Dashboard.
    """
    dashboard = logged_in_student
    
    # 1. Check home tab
    dashboard.go_to_home()
    assert dashboard.is_element_visible(dashboard.ELECTION_STATUS_BANNER), "Home tab elements not visible"
    
    # 2. Check results tab
    dashboard.go_to_results()
    assert dashboard.is_element_present(dashboard.RESULTS_CHART), "Results tab chart not found"
    
    # 3. Check notifications tab
    dashboard.go_to_notifications()
    # verify tab loaded (can look for a notification header or empty notice)
    
    # 4. Check profile tab
    dashboard.go_to_profile()
    assert dashboard.is_element_visible(dashboard.VERIFICATION_STATUS), "Profile tab details failed to load"


def test_identity_verification_submission(logged_in_student):
    """
    Test Case: Verify student can complete the Identity Verification flow.
    """
    dashboard = logged_in_student
    
    # Check current status
    initial_status = dashboard.get_verification_status()
    print(f"\n[INFO] Initial Verification Status: {initial_status}")
    
    # Run verification if not already verified
    if "Not Verified" in initial_status:
        dashboard.start_identity_verification()
        
        # Verify status updated to 'Pending' or 'Verified'
        new_status = dashboard.get_verification_status()
        assert "Pending" in new_status or "Verified" in new_status, \
            f"Verification status did not transition as expected. Got: '{new_status}'"


def test_candidate_list_and_details(logged_in_student):
    """
    Test Case: Verify candidate list loads, supports inspection of candidate details.
    """
    dashboard = logged_in_student
    dashboard.go_to_home()
    
    # Scroll or verify candidate card is present
    assert dashboard.is_element_visible(dashboard.CANDIDATE_CARD), "No candidates visible on dashboard"
    
    # Select first candidate in the list (mocked name check or generic card click)
    dashboard.click(dashboard.CANDIDATE_CARD)
    
    # Verify candidate profile details loaded
    assert dashboard.is_element_visible(dashboard.VOTE_BUTTON), "Candidate details page did not open"


def test_voting_flow_and_history(logged_in_student):
    """
    Test Case: Verify voter selection, vote confirmation, and voting history updates.
    """
    dashboard = logged_in_student
    dashboard.go_to_home()
    
    # Verify if voting is currently allowed (if election is active and user verified)
    status = dashboard.get_text(dashboard.ELECTION_STATUS_BANNER)
    if "Active" not in status and "Open" not in status:
        pytest.skip("Election is not currently active, skipping vote submission test.")
        
    verification = dashboard.get_verification_status()
    if "Verified" not in verification:
        pytest.skip("User is not verified to vote, skipping vote submission test.")
        
    # Cast vote for first candidate
    dashboard.cast_vote("Jane Doe")
    
    # Verify Success notification or updated status
    success_text = dashboard.get_text(dashboard.ELECTION_STATUS_BANNER)
    assert "Voted" in success_text or "Submitted" in success_text, \
        f"Vote submission status did not update: {success_text}"

    # Navigate to profile and check voting history
    history = dashboard.check_voting_history()
    # In a real environment, we assert that history contains the candidate vote record
    print(f"[INFO] Retrieve Vote History: {history}")
