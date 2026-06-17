import os
import time
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from appium.webdriver.common.appiumby import AppiumBy

class BasePage:
    """
    Base class for all Page Objects in the Appium test suite.
    Wraps standard Appium actions and provides robust wait strategies.
    """
    def __init__(self, driver):
        self.driver = driver
        self.timeout = 10

    def find_element(self, locator, timeout=None):
        """Finds a single element, waiting for its presence."""
        t = timeout or self.timeout
        try:
            return WebDriverWait(self.driver, t).until(
                EC.presence_of_element_located(locator)
            )
        except TimeoutException:
            print(f"[ERROR] Element not found within {t}s: {locator}")
            raise NoSuchElementException(f"Could not locate element using: {locator}")

    def find_elements(self, locator, timeout=None):
        """Finds multiple elements, waiting for presence."""
        t = timeout or self.timeout
        try:
            return WebDriverWait(self.driver, t).until(
                EC.presence_of_all_elements_located(locator)
            )
        except TimeoutException:
            return []

    def click(self, locator, timeout=None):
        """Waits for element to be clickable, then clicks it."""
        t = timeout or self.timeout
        try:
            element = WebDriverWait(self.driver, t).until(
                EC.element_to_be_clickable(locator)
            )
            element.click()
            time.sleep(0.5) # Allow interface transition animation
        except TimeoutException:
            print(f"[ERROR] Element not clickable within {t}s: {locator}")
            raise

    def send_keys(self, locator, text, clear=True, timeout=None):
        """Waits for element to be visible, enters text."""
        t = timeout or self.timeout
        try:
            element = WebDriverWait(self.driver, t).until(
                EC.visibility_of_element_located(locator)
            )
            if clear:
                element.clear()
            element.send_keys(text)
        except TimeoutException:
            print(f"[ERROR] Input element not visible within {t}s: {locator}")
            raise

    def get_text(self, locator, timeout=None):
        """Retrieves text or content-desc from element."""
        element = self.find_element(locator, timeout)
        
        # In Flutter on Android, text might be in 'text' property or 'content-desc' (accessibility label)
        text = element.text
        if not text:
            text = element.get_attribute("content-desc")
        return text or ""

    def is_element_present(self, locator, timeout=None):
        """Checks if an element is present in the DOM (no exception raised)."""
        t = timeout or 3
        try:
            WebDriverWait(self.driver, t).until(
                EC.presence_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False

    def is_element_visible(self, locator, timeout=None):
        """Checks if an element is visible on screen."""
        t = timeout or 3
        try:
            WebDriverWait(self.driver, t).until(
                EC.visibility_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False

    def take_screenshot(self, name):
        """Takes a manual screenshot and saves it to Failed_Test_Screenshots."""
        screenshot_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
            "Appium_Test_Results", 
            "Failed_Test_Screenshots"
        )
        os.makedirs(screenshot_dir, exist_ok=True)
        path = os.path.join(screenshot_dir, f"{name}_{int(time.time())}.png")
        self.driver.save_screenshot(path)
        print(f"[INFO] Manual screenshot saved: {path}")
        return path

    def hide_keyboard_if_present(self):
        """Safely hides soft keyboard if active."""
        try:
            if self.driver.is_keyboard_shown():
                self.driver.hide_keyboard()
        except Exception:
            pass
