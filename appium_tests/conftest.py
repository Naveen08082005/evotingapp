import os
import time
import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

# Define paths
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APK_PATH = os.path.join(PROJECT_ROOT, "build", "app", "outputs", "flutter-apk", "app-debug.apk")
SCREENSHOT_DIR = os.path.join(PROJECT_ROOT, "Appium_Test_Results", "Failed_Test_Screenshots")

# Ensure screenshot directory exists
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

@pytest.fixture(scope="function")
def driver(request):
    """
    Setup Appium driver for Android testing.
    """
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.automation_name = "UiAutomator2"
    options.device_name = "Android Emulator"
    options.app = APK_PATH
    options.app_package = "com.evoting.evoting_app"
    options.app_activity = "com.evoting.evoting_app.MainActivity"
    
    # Reset behaviors: 
    # - fullReset = True guarantees clean state for every test session (wipes cache/storage, uninstalls and reinstalls APK).
    options.no_reset = False
    options.full_reset = True
    options.auto_grant_permissions = True
    
    # Standard Appium server URL
    appium_server_url = "http://localhost:4723"
    
    print(f"\n[INFO] Connecting to Appium Server at {appium_server_url}...")
    print(f"[INFO] Launching APK: {APK_PATH}")
    
    # Under real execution, this connects to the Appium server.
    # We add exception handling to make the script resilient and document failures clearly.
    try:
        driver = webdriver.Remote(command_executor=appium_server_url, options=options)
        driver.implicitly_wait(10) # 10 seconds implicit wait
    except Exception as e:
        print(f"[ERROR] Failed to connect to Appium Server or launch APK: {e}")
        # When running in a mocked or developer-only offline execution environment, 
        # we can yield None or raise an exception to stop tests gracefully.
        raise RuntimeError(
            f"Appium Server or Emulator connection failed. Ensure Appium is running "
            f"at {appium_server_url} and a device is connected. Original error: {e}"
        )

    yield driver
    
    # Clean up and quit
    print("[INFO] Terminating session and quitting driver...")
    try:
        driver.quit()
    except Exception:
        pass

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """
    Captures screenshots on test failure.
    """
    # Execute all other hooks to obtain the report object
    outcome = yield
    rep = outcome.get_result()
    
    # Check if the test failed during setup, call, or teardown
    if rep.failed:
        # Get the driver fixture from the test item
        driver_fixture = item.funcargs.get("driver") if "driver" in item.funcargs else None
        if driver_fixture:
            try:
                test_name = item.name.replace("[", "_").replace("]", "_")
                timestamp = int(time.time())
                screenshot_filename = f"{test_name}_{timestamp}.png"
                screenshot_path = os.path.join(SCREENSHOT_DIR, screenshot_filename)
                
                print(f"\n[FAILURE] Test '{item.name}' failed. Taking screenshot...")
                driver_fixture.save_screenshot(screenshot_path)
                print(f"[FAILURE] Screenshot saved to: {screenshot_path}")
            except Exception as e:
                print(f"[ERROR] Failed to save failure screenshot: {e}")

@pytest.fixture
def admin_credentials():
    return {
        "email": "admin@college.edu",
        "password": "AdminPassword#2026"
    }

@pytest.fixture
def student_credentials():
    return {
        "email": "student@college.edu",
        "password": "StudentPassword#2026",
        "register_num": "22CS045"
    }
