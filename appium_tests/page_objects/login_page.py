from appium.webdriver.common.appiumby import AppiumBy
from page_objects.base_page import BasePage

class LoginPage(BasePage):
    """
    Page Object containing locators and actions for Authentication screens:
    Login, Registration, and Forgot Password.
    """
    
    # Locators (using standard Android properties exposed by Flutter Semantics)
    # Fields
    EMAIL_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Email') or contains(@text, 'Email') or @index=0]")
    PASSWORD_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Password') or contains(@text, 'Password') or @index=1]")
    REG_NUM_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Register Number') or contains(@text, 'Register Number')]")
    
    # Buttons & Links
    LOGIN_BUTTON = (AppiumBy.XPATH, "//*[@text='Login' or @content-desc='Login' or @index=3]")
    FORGOT_PASSWORD_LINK = (AppiumBy.XPATH, "//*[@text='Forgot Password?' or @content-desc='Forgot Password?']")
    REGISTER_LINK = (AppiumBy.XPATH, "//*[contains(@text, 'Register') or contains(@content-desc, 'Register') or contains(@text, 'Don\'t have an account')]")
    
    # Registration Screen Specifics
    DEPT_DROPDOWN = (AppiumBy.XPATH, "//*[contains(@text, 'Select Department') or contains(@content-desc, 'Select Department')]")
    DEPT_OPTION_CS = (AppiumBy.XPATH, "//*[@text='Computer Science' or @content-desc='Computer Science']")
    REGISTER_BUTTON = (AppiumBy.XPATH, "//*[@text='Register' or @content-desc='Register']")
    
    # Forgot Password Screen Specifics
    RESET_PASSWORD_BUTTON = (AppiumBy.XPATH, "//*[@text='Reset Password' or @content-desc='Reset Password' or contains(@text, 'Send')]")
    BACK_TO_LOGIN_LINK = (AppiumBy.XPATH, "//*[@text='Back to Login' or @content-desc='Back to Login']")

    # Errors & Status
    SNACKBAR_MESSAGE = (AppiumBy.XPATH, "//*[contains(@text, 'error') or contains(@text, 'failed') or contains(@text, 'invalid') or contains(@text, 'Wrong') or contains(@text, 'invalid login')]")
    VALIDATION_ERROR = (AppiumBy.XPATH, "//*[contains(@text, 'Required') or contains(@text, 'invalid') or contains(@text, 'must be')]")

    # Actions
    def login(self, email, password):
        """Perform login action."""
        self.send_keys(self.EMAIL_FIELD, email)
        self.send_keys(self.PASSWORD_FIELD, password)
        self.hide_keyboard_if_present()
        self.click(self.LOGIN_BUTTON)

    def navigate_to_register(self):
        """Navigate to registration screen."""
        self.click(self.REGISTER_LINK)

    def navigate_to_forgot_password(self):
        """Navigate to forgot password screen."""
        self.click(self.FORGOT_PASSWORD_LINK)

    def register(self, email, password, reg_num, department="Computer Science"):
        """Perform student registration."""
        self.send_keys(self.EMAIL_FIELD, email)
        self.send_keys(self.PASSWORD_FIELD, password)
        self.send_keys(self.REG_NUM_FIELD, reg_num)
        
        # Select department dropdown
        self.click(self.DEPT_DROPDOWN)
        self.click(self.DEPT_OPTION_CS)
        
        self.hide_keyboard_if_present()
        self.click(self.REGISTER_BUTTON)

    def request_password_reset(self, email):
        """Submit forgot password request."""
        self.send_keys(self.EMAIL_FIELD, email)
        self.hide_keyboard_if_present()
        self.click(self.RESET_PASSWORD_BUTTON)

    def get_snackbar_text(self):
        """Retrieve any active snackbar error/success message."""
        try:
            return self.get_text(self.SNACKBAR_MESSAGE, timeout=5)
        except Exception:
            return ""

    def get_validation_error_text(self):
        """Retrieve form validation error message if visible."""
        try:
            return self.get_text(self.VALIDATION_ERROR, timeout=3)
        except Exception:
            return ""
