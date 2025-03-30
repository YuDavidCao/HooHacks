from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# Set up Chrome options (optional)
options = webdriver.ChromeOptions()

# Initialize the driver (make sure the path is set correctly)
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# Go to a website
driver.get('https://www.virginia.edu/calendar/')

# Wait for the page to load (optional)
driver.implicitly_wait(4)

# Find elements using various methods
card = driver.find_elements(By.CLASS_NAME, 'twTileGridEvent')
event_name = driver.find_elements(By.CLASS_NAME, "twTitle")

for event in event_name: 
    print(event.text)

# Interact with the page (example: sending text into a search box

# Wait for results and extract some data

# Don't forget to close the driver when you're done
driver.quit()