import time
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

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
        driver = webdriver.Chrome(options=chrome_options)
    except Exception:
        from selenium.webdriver.chrome.service import Service
        from webdriver_manager.chrome import ChromeDriverManager
        driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
        
    try:
        driver.get(BASE_URL)
        
        print("Waiting for Flutter app initialization...")
        # Wait up to 30 seconds for the Flutter engine to mount the canvas (flt-glass-pane)
        WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.TAG_NAME, "flt-glass-pane"))
        )
        
        title = driver.title
        print(f"Loaded page title: {title}")
        assert "evoting" in title.lower() or "e-voting" in title.lower(), f"Unexpected page title: {title}"
        
        print("✅ Selenium E2E smoke test passed: Flutter app successfully loaded and initialized")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()

