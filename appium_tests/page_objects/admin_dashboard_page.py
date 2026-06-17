from appium.webdriver.common.appiumby import AppiumBy
from page_objects.base_page import BasePage
import time

class AdminDashboardPage(BasePage):
    """
    Page Object containing locators and actions for the Admin Module screens:
    Admin Dashboard, Candidate Management (Add/Edit/Delete), User Management (Verifications),
    Election Controls (Start/Stop/Reset), and Results Dashboard.
    """
    
    # Navigation & Stats
    MANAGE_CANDIDATES_BUTTON = (AppiumBy.XPATH, "//*[@text='Manage Candidates' or @content-desc='Manage Candidates']")
    MANAGE_USERS_BUTTON = (AppiumBy.XPATH, "//*[@text='Manage Users' or @content-desc='Manage Users']")
    ELECTION_SETTINGS_BUTTON = (AppiumBy.XPATH, "//*[@text='Election Settings' or @content-desc='Election Settings']")
    ADMIN_LOGOUT_BUTTON = (AppiumBy.XPATH, "//*[@text='Logout' or @content-desc='Logout' or contains(@text, 'Sign Out')]")
    
    # Candidate Management Screen
    ADD_CANDIDATE_FAB = (AppiumBy.XPATH, "//android.widget.Button[@content-desc='Add Candidate' or contains(@text, '+') or @index=1]") # floating action button
    CANDIDATE_ITEM_OPTIONS = (AppiumBy.XPATH, "//*[contains(@content-desc, 'More options') or contains(@text, 'Options')]")
    EDIT_OPTION = (AppiumBy.XPATH, "//*[@text='Edit' or @content-desc='Edit']")
    DELETE_OPTION = (AppiumBy.XPATH, "//*[@text='Delete' or @content-desc='Delete']")
    CONFIRM_DELETE_BUTTON = (AppiumBy.XPATH, "//*[@text='Yes, Delete' or @text='Delete' or @content-desc='Confirm Delete']")

    # Add/Edit Candidate Form
    CANDIDATE_NAME_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Name') or contains(@text, 'Name')]")
    CANDIDATE_BIO_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Bio') or contains(@text, 'Bio') or contains(@hint, 'Description')]")
    CANDIDATE_SYMBOL_FIELD = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Symbol') or contains(@text, 'Symbol')]")
    CANDIDATE_DEPT_DROPDOWN = (AppiumBy.XPATH, "//*[contains(@text, 'Select Department') or contains(@content-desc, 'Select Department')]")
    CANDIDATE_IMAGE_PICKER = (AppiumBy.XPATH, "//*[contains(@text, 'Pick Image') or contains(@content-desc, 'Pick Image')]")
    SAVE_CANDIDATE_BUTTON = (AppiumBy.XPATH, "//*[@text='Save' or @text='Add' or @content-desc='Save' or @content-desc='Add']")
    
    # User Management Screen
    PENDING_USER_ROW = (AppiumBy.XPATH, "//*[contains(@text, 'Pending') or contains(@content-desc, 'Pending')]")
    APPROVE_USER_BUTTON = (AppiumBy.XPATH, "//*[@text='Approve' or @content-desc='Approve']")
    REJECT_USER_BUTTON = (AppiumBy.XPATH, "//*[@text='Reject' or @content-desc='Reject']")
    
    # Election Settings Screen
    CREATE_ELECTION_BUTTON = (AppiumBy.XPATH, "//*[@text='Create New Election' or @content-desc='Create Election']")
    START_ELECTION_BUTTON = (AppiumBy.XPATH, "//*[@text='Start Election' or @content-desc='Start Election']")
    STOP_ELECTION_BUTTON = (AppiumBy.XPATH, "//*[@text='Stop Election' or @content-desc='Stop Election']")
    RESET_ELECTION_BUTTON = (AppiumBy.XPATH, "//*[@text='Reset Election' or @content-desc='Reset Election']")
    CONFIRM_RESET_BUTTON = (AppiumBy.XPATH, "//*[@text='Reset' or @text='Yes, Reset' or @content-desc='Confirm Reset']")

    # Actions
    def go_to_candidate_management(self):
        self.click(self.MANAGE_CANDIDATES_BUTTON)

    def go_to_user_management(self):
        self.click(self.MANAGE_USERS_BUTTON)

    def go_to_election_settings(self):
        self.click(self.ELECTION_SETTINGS_BUTTON)

    def admin_logout(self):
        self.click(self.ADMIN_LOGOUT_BUTTON)

    def add_candidate(self, name, bio, symbol, department="Computer Science"):
        """Fills form to add a candidate."""
        self.go_to_candidate_management()
        self.click(self.ADD_CANDIDATE_FAB)
        
        self.send_keys(self.CANDIDATE_NAME_FIELD, name)
        self.send_keys(self.CANDIDATE_BIO_FIELD, bio)
        self.send_keys(self.CANDIDATE_SYMBOL_FIELD, symbol)
        
        # Selection of department dropdown if available
        if self.is_element_present(self.CANDIDATE_DEPT_DROPDOWN, timeout=2):
            self.click(self.CANDIDATE_DEPT_DROPDOWN)
            # select first option matching CS
            self.click((AppiumBy.XPATH, f"//*[@text='{department}']"))

        # Skip image picking in mock/default testing run unless test checks storage
        self.hide_keyboard_if_present()
        self.click(self.SAVE_CANDIDATE_BUTTON)
        time.sleep(1) # Allow completion

    def delete_candidate(self, candidate_name):
        """Finds candidate by name, opens options, and deletes."""
        self.go_to_candidate_management()
        candidate_options = (AppiumBy.XPATH, f"//*[contains(@text, '{candidate_name}')]/following-sibling::*[contains(@content-desc, 'options') or @index=2]")
        self.click(candidate_options)
        self.click(self.DELETE_OPTION)
        self.click(self.CONFIRM_DELETE_BUTTON)
        time.sleep(1)

    def approve_first_pending_user(self):
        """Approves the first pending student verification request."""
        self.go_to_user_management()
        if self.is_element_present(self.PENDING_USER_ROW):
            self.click(self.PENDING_USER_ROW)
            self.click(self.APPROVE_USER_BUTTON)
            return True
        return False

    def change_election_state(self, state):
        """Transitions election state ('start', 'stop', 'reset')."""
        self.go_to_election_settings()
        if state == "start":
            self.click(self.START_ELECTION_BUTTON)
        elif state == "stop":
            self.click(self.STOP_ELECTION_BUTTON)
        elif state == "reset":
            self.click(self.RESET_ELECTION_BUTTON)
            self.click(self.CONFIRM_RESET_BUTTON)
        time.sleep(1)
