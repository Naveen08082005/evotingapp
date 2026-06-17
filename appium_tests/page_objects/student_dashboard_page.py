from appium.webdriver.common.appiumby import AppiumBy
from page_objects.base_page import BasePage
import time

class StudentDashboardPage(BasePage):
    """
    Page Object containing locators and actions for the Student/User module screens:
    Dashboard navigation, Profile, Verification, Candidates List, Candidates Details,
    Voting, Voting History, Notifications, and Live Results.
    """
    
    # Navigation Tabs (BottomNavigationBar)
    HOME_TAB = (AppiumBy.XPATH, "//android.widget.ImageView[contains(@content-desc, 'Home') or contains(@text, 'Home') or @index=0]")
    RESULTS_TAB = (AppiumBy.XPATH, "//android.widget.ImageView[contains(@content-desc, 'Results') or contains(@text, 'Results') or @index=1]")
    NOTIFICATIONS_TAB = (AppiumBy.XPATH, "//android.widget.ImageView[contains(@content-desc, 'Notifications') or contains(@text, 'Notifications') or @index=2]")
    PROFILE_TAB = (AppiumBy.XPATH, "//android.widget.ImageView[contains(@content-desc, 'Profile') or contains(@text, 'Profile') or @index=3]")
    
    # Home Screen / Dashboard Elements
    ELECTION_STATUS_BANNER = (AppiumBy.XPATH, "//*[contains(@text, 'Election') or contains(@content-desc, 'Election')]")
    CANDIDATE_CARD = (AppiumBy.XPATH, "//*[contains(@text, 'Candidate') or contains(@content-desc, 'Candidate') or contains(@text, 'Vote')]")
    CANDIDATES_LIST = (AppiumBy.XPATH, "//android.widget.ListView or //android.widget.ScrollView")
    
    # Candidate Details Screen
    CANDIDATE_NAME = (AppiumBy.XPATH, "//*[@index=1 and android.widget.TextView]") # general fallback
    VOTE_BUTTON = (AppiumBy.XPATH, "//*[@text='Vote' or @content-desc='Vote']")
    CONFIRM_VOTE_BUTTON = (AppiumBy.XPATH, "//*[@text='Yes, Confirm' or @content-desc='Confirm' or @text='Confirm']")
    
    # Profile Screen
    LOGOUT_BUTTON = (AppiumBy.XPATH, "//*[@text='Logout' or @content-desc='Logout' or contains(@text, 'Sign Out')]")
    VERIFICATION_STATUS = (AppiumBy.XPATH, "//*[contains(@text, 'Verified') or contains(@text, 'Pending') or contains(@text, 'Not Verified')]")
    VERIFY_IDENTITY_BUTTON = (AppiumBy.XPATH, "//*[@text='Verify Identity' or @content-desc='Verify Identity']")
    
    # Identity Verification Screen
    UPLOAD_ID_BUTTON = (AppiumBy.XPATH, "//*[contains(@text, 'Upload') or contains(@content-desc, 'Upload')]")
    SUBMIT_VERIFICATION_BUTTON = (AppiumBy.XPATH, "//*[@text='Submit' or @content-desc='Submit']")
    
    # Voting History Screen (accessed from Profile or Dashboard)
    VOTING_HISTORY_BUTTON = (AppiumBy.XPATH, "//*[@text='Voting History' or @content-desc='Voting History']")
    HISTORY_LIST_ITEM = (AppiumBy.XPATH, "//*[contains(@text, 'Voted for') or contains(@content-desc, 'Voted')]")
    
    # Live Results Screen
    RESULTS_CHART = (AppiumBy.XPATH, "//*[contains(@content-desc, 'chart') or contains(@content-desc, 'Winner') or contains(@text, 'Votes')]")

    # Actions
    def go_to_home(self):
        self.click(self.HOME_TAB)

    def go_to_results(self):
        self.click(self.RESULTS_TAB)

    def go_to_notifications(self):
        self.click(self.NOTIFICATIONS_TAB)

    def go_to_profile(self):
        self.click(self.PROFILE_TAB)

    def logout(self):
        self.go_to_profile()
        self.click(self.LOGOUT_BUTTON)

    def start_identity_verification(self):
        self.go_to_profile()
        self.click(self.VERIFY_IDENTITY_BUTTON)
        # Standard flow allows taking or uploading a photo
        self.click(self.UPLOAD_ID_BUTTON)
        # Mock file picker interaction in automation
        time.sleep(1)
        self.click(self.SUBMIT_VERIFICATION_BUTTON)

    def get_verification_status(self):
        self.go_to_profile()
        return self.get_text(self.VERIFICATION_STATUS)

    def view_candidate_details(self, candidate_name):
        """Clicks on a candidate in the list by name."""
        candidate_locator = (AppiumBy.XPATH, f"//*[contains(@text, '{candidate_name}') or contains(@content-desc, '{candidate_name}')]")
        self.click(candidate_locator)

    def cast_vote(self, candidate_name):
        """Navigate to candidate, click vote, and confirm."""
        self.view_candidate_details(candidate_name)
        self.click(self.VOTE_BUTTON)
        self.click(self.CONFIRM_VOTE_BUTTON)

    def check_voting_history(self):
        """Navigate to voting history page and return visible text of entries."""
        self.go_to_profile()
        self.click(self.VOTING_HISTORY_BUTTON)
        items = self.find_elements(self.HISTORY_LIST_ITEM)
        return [self.get_text(item) for item in items]
        
    def has_results_loaded(self):
        """Verifies if the charts/results are shown on Results tab."""
        self.go_to_results()
        return self.is_element_present(self.RESULTS_CHART)
