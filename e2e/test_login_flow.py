import time
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

BASE_URL = "http://localhost:8000"

def wait_for_server():
    for _ in range(30):
        try:
            if requests.get(BASE_URL).status_code == 200:
                return
        except Exception:
            pass
        time.sleep(1)
    raise RuntimeError("Web server did not start in time")

def main():
    wait_for_server()
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    
    try:
        # Modern Selenium 4 handles driver download natively
        driver = webdriver.Chrome(options=chrome_options)
    except Exception:
        # Fallback to webdriver_manager if required
        from selenium.webdriver.chrome.service import Service
        driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    try:
        driver.get(BASE_URL)
        assert "E‑Voting" in driver.title, "Home page title missing"
        login_btn = driver.find_element("xpath", "//button[contains(text(),'Admin Login')]")
        login_btn.click()
        time.sleep(1)
        driver.find_element("name", "email").send_keys("testadmin@example.com")
        driver.find_element("name", "password").send_keys("password123")
        driver.find_element("xpath", "//button[contains(text(),'Login')]").click()
        time.sleep(2)
        assert "Admin Dashboard" in driver.page_source, "Login failed"
        print("✅ Selenium E2E test passed")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()
