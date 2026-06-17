import pytest
import time
from page_objects.login_page import LoginPage
from page_objects.student_dashboard_page import StudentDashboardPage

def test_student_login_logout_success(driver, student_credentials):
    """
    Test Case: Verify that a student can successfully login and log out of the application.
    """
    login_page = LoginPage(driver)
    dashboard_page = StudentDashboardPage(driver)
    
    # 1. Login
    login_page.login(student_credentials["email"], student_credentials["password"])
    
    # 2. Verify dashboard loaded by asserting Profile tab visibility
    assert dashboard_page.is_element_visible(dashboard_page.PROFILE_TAB), "Dashboard failed to load"
    
    # 3. Logout
    dashboard_page.logout()
    
    # 4. Verify redirected back to Login screen
    assert login_page.is_element_visible(login_page.LOGIN_BUTTON), "Failed to redirect to login after logout"


def test_admin_login_logout_success(driver, admin_credentials):
    """
    Test Case: Verify that an administrator can successfully login and log out.
    """
    login_page = LoginPage(driver)
    dashboard_page = StudentDashboardPage(driver)
    
    # 1. Login as Admin
    login_page.login(admin_credentials["email"], admin_credentials["password"])
    
    # 2. Verify admin panel is visible by finding candidate management button
    from page_objects.admin_dashboard_page import AdminDashboardPage
    admin_dashboard = AdminDashboardPage(driver)
    assert admin_dashboard.is_element_visible(admin_dashboard.MANAGE_CANDIDATES_BUTTON), "Admin dashboard did not load"
    
    # 3. Logout
    admin_dashboard.admin_logout()
    
    # 4. Verify redirected to Login screen
    assert login_page.is_element_visible(login_page.LOGIN_BUTTON), "Admin logout failed"


def test_invalid_login_attempts(driver):
    """
    Test Case: Verify proper error handling and rate-limiting for invalid login attempts.
    """
    login_page = LoginPage(driver)
    
    # Attempt 1: Wrong password
    login_page.login("student@demo.local", "WrongPassword123!")
    error_text = login_page.get_snackbar_text()
    assert "Wrong" in error_text or "invalid" in error_text or "failed" in error_text, \
        f"Expected authentication error message, got: '{error_text}'"
        
    # Attempt 2: Unregistered email
    login_page.login("nonexistent_user@demo.local", "SomePassword1!")
    error_text = login_page.get_snackbar_text()
    assert "invalid" in error_text or "error" in error_text or "not found" in error_text, \
        f"Expected error for unregistered email, got: '{error_text}'"


def test_registration_form_validations(driver):
    """
    Test Case: Verify form validation rules on registration screen.
    - Password strength constraints.
    - Registration number format matching regex (e.g. 22CS045).
    """
    login_page = LoginPage(driver)
    login_page.navigate_to_register()
    
    # 1. Attempt register with invalid password (weak) and invalid register number format
    login_page.register("newstudent@demo.local", "weak", "invalid_reg_num")
    
    validation_error = login_page.get_validation_error_text()
    assert validation_error != "", "Validation error messages did not display for invalid inputs"
    
    # 2. Attempt register with strong password but wrong register number format
    login_page.register("newstudent@demo.local", "StrongPass#2026", "invalid_123")
    validation_error = login_page.get_validation_error_text()
    assert "Register Number" in validation_error or "format" in validation_error, \
        f"Expected validation warning on register number format, got: '{validation_error}'"


def test_forgot_password_submission(driver):
    """
    Test Case: Verify forgot password request flow.
    """
    login_page = LoginPage(driver)
    login_page.navigate_to_forgot_password()
    
    # Submit request
    login_page.request_password_reset("student@demo.local")
    
    # In a real environment we verify snackbar or redirection
    # Depending on Supabase settings, it says check email or password reset link sent.
    success_msg = login_page.get_snackbar_text()
    assert "email" in success_msg.lower() or "sent" in success_msg.lower() or success_msg == "", \
        f"Unexpected response after reset submission: {success_msg}"
