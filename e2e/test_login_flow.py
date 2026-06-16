import time
import requests
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

BASE_URL = "http://localhost:8000"

@pytest.fixture(scope="module")
def driver():
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
        
    yield driver
    driver.quit()

def test_wait_for_server():
    """Verify that the local web server is up and reachable."""
    started = False
    for _ in range(30):
        try:
            if requests.get(BASE_URL).status_code == 200:
                started = True
                break
        except Exception:
            pass
        time.sleep(1)
    assert started, "Web server did not start in time"

def test_flutter_web_initialization(driver):
    """Verify that the Flutter app loads and boots without JavaScript or rendering failures."""
    driver.get(BASE_URL)
    
    print("Waiting for Flutter app initialization...")
    # Wait up to 30 seconds for the Flutter engine to mount the canvas (flt-glass-pane)
    WebDriverWait(driver, 30).until(
        EC.presence_of_element_located((By.TAG_NAME, "flt-glass-pane"))
    )
    
    title = driver.title
    print(f"Loaded page title: {title}")
    assert "evoting" in title.lower() or "e-voting" in title.lower(), f"Unexpected page title: {title}"


