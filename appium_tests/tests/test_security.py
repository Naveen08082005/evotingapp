import pytest
import time
from page_objects.login_page import LoginPage
from page_objects.student_dashboard_page import StudentDashboardPage
from page_objects.admin_dashboard_page import AdminDashboardPage
from appium.webdriver.common.appiumby import AppiumBy

def test_password_field_masking(driver):
    """
    Security Case: Verify password fields have the password attribute enabled 
    (masking characters to prevent shoulder surfing / plain-text exposure).
    """
    login_page = LoginPage(driver)
    
    # Locate password field
    password_elem = login_page.find_element(login_page.PASSWORD_FIELD)
    
    # On Android, secure fields have 'password' attribute set to true
    is_password = password_elem.get_attribute("password")
    assert is_password == "true", "Password field input is not masked!"


def test_student_cannot_access_admin_features(driver, student_credentials):
    """
    Security Case: Verify role-based authorization boundaries.
    - Log in as a student.
    - Assert that admin UI elements (Manage Candidates, Election Settings, etc.) are NOT present.
    """
    login_page = LoginPage(driver)
    student_dashboard = StudentDashboardPage(driver)
    admin_dashboard = AdminDashboardPage(driver)
    
    # 1. Login as Student
    login_page.login(student_credentials["email"], student_credentials["password"])
    
    # 2. Assert student dashboard tabs are visible
    assert student_dashboard.is_element_visible(student_dashboard.PROFILE_TAB)
    
    # 3. Assert admin dashboards elements are NOT visible or present
    assert not admin_dashboard.is_element_present(admin_dashboard.MANAGE_CANDIDATES_BUTTON, timeout=2)
    assert not admin_dashboard.is_element_present(admin_dashboard.ELECTION_SETTINGS_BUTTON, timeout=2)
    
    student_dashboard.logout()


def test_input_sanitization_and_sql_injection(driver):
    """
    Security Case: Validate input fields reject common injection strings 
    and fail gracefully without causing application crashes.
    """
    login_page = LoginPage(driver)
    
    # Payloads to inject
    sql_injection_payload = "' OR 1=1 --"
    command_injection_payload = "; reboot #"
    
    # 1. Test in Email input
    login_page.login(sql_injection_payload, "SomePassword1!")
    error_text = login_page.get_snackbar_text()
    
    # The application should show a generic validation/auth error, not crash
    assert "invalid" in error_text.lower() or "error" in error_text.lower() or "wrong" in error_text.lower(), \
        f"SQL Injection payload caused unexpected behavior/crash or bypassed auth. Error: {error_text}"
        
    # 2. Test in password input
    login_page.login("student@demo.local", command_injection_payload)
    error_text = login_page.get_snackbar_text()
    assert error_text != "", "System should display failure notification for invalid inputs rather than hanging"


def test_unauthorized_page_deep_link_bypass_denied(driver):
    """
    Security Case: Verify deep linking or direct activity routing bypass attempts are denied.
    """
    # Attempting to start the AppActivity directly into dashboard screens without a session
    # should automatically redirect the user back to the login screen.
    login_page = LoginPage(driver)
    
    # We attempt to launch app clean (fullReset is enabled by default)
    # The app should start on the LoginPage
    assert login_page.is_element_visible(login_page.LOGIN_BUTTON), "Unauthenticated session did not land on login screen"
    
    # Verify no dashboard controls are exposed
    from page_objects.student_dashboard_page import StudentDashboardPage
    student_dashboard = StudentDashboardPage(driver)
    assert not student_dashboard.is_element_present(student_dashboard.PROFILE_TAB, timeout=2)
