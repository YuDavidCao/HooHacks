from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import random
from datetime import datetime, timedelta, timezone
import random
import json
import string
import uuid 
import requests  
from google import genai
from dotenv import load_dotenv
import os

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
gemini_client = genai.Client(api_key=GEMINI_API_KEY)

def scrape():
    driver = webdriver.Chrome()

    driver.get("https://www.virginia.edu/calendar/")  # Replace with correct page URL

    # Wait for the iframe to be present and switch to it
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "trumba.spud.5.iframe")))
    iframe = driver.find_element(By.ID, "trumba.spud.5.iframe")
    driver.switch_to.frame(iframe)

    # Wait for the link elements to be present
    link_elements = WebDriverWait(driver, 10).until(
        EC.presence_of_all_elements_located((By.CSS_SELECTOR, "a.twTitle"))
    )

    location_elements = WebDriverWait(driver, 10).until(
        EC.presence_of_all_elements_located((By.CSS_SELECTOR, "div.singleLine a:not(.twLocation a)"))
    )

    image_sources = []

    linked_images = driver.find_elements(By.CSS_SELECTOR, "a > img")
            
    # Extract and print src attributes
    for img in linked_images:
        src = img.get_attribute("src")
        image_sources.append(src)
    
    write_json(link_elements, location_elements, image_sources)

    driver.quit()

def generate_event_description(event_title):
    """Generates an event description using Gemini based on the event title."""
    try:
        prompt = f"Write a short, direct description for the event: '{event_title}'. Keep it to one or two sentences. Only type the description and nothing else."
        response = gemini_client.models.generate_content(
            model="gemini-2.0-flash",
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        print(f"Error generating description for '{event_title}': {e}")
        return "Event description not available."

def generate_random_date_week_ahead():
    """Generates a random datetime at least a week ahead."""
    today = datetime.now(timezone.utc)
    one_week_later = today + timedelta(days=7)
    max_date = today + timedelta(days=30)  # Maximum 30 days ahead
    return generate_random_date_between(one_week_later, max_date)

def generate_random_date_between(start_date, end_date):
    """Generates a random datetime between start_date and end_date."""
    return start_date + timedelta(seconds=random.randint(0, int((end_date - start_date).total_seconds())))

def generate_random_participants():
    """Generates a list of random participants."""
    num_participants = random.randint(0, 100)
    return ["user" + str(random.randint(1, 1000)) for _ in range(num_participants)]

def generate_random_email():
    """Generates a 5-character random email ending with @virginia.edu."""
    characters = string.ascii_letters + string.digits  # Letters and numbers
    random_part = ''.join(random.choice(characters) for _ in range(5))
    return f"{random_part}@virginia.edu"

def create_simple_event_json(title, description, end_date, id):
    """
    Creates a simple JSON dictionary with title, description, id, and end_date.

    Args:
        title (str): The title of the event.
        description (str): The description of the event.
        end_date (str): The end date of the event in ISO format.

    Returns:
        dict: A dictionary representing the event data.
    """
    if isinstance(end_date, str):
        end_date = datetime.fromisoformat(end_date)

    event_data = {
        "Title": title,
        "Description": description,
        "Id": id,
        "EndDate": end_date.timestamp()
    }
    print(event_data)
    return event_data

def get_organization_name(event_title):
    """Generates an organization using Gemini based on the event title."""
    try:
        prompt = f"Write an organization named based at the University of Virginia based on the title of the event: '{event_title}'. Only type the organization name and nothing else."
        response = gemini_client.models.generate_content(
            model="gemini-2.0-flash",
            contents=[prompt]
        )
        return response.text.strip()
    except Exception as e:
        print(f"Error generating description for '{event_title}': {e}")
        return "Event description not available."

def write_json(link_elements, location_elements, image_sources, output_file='events.json'):
    event_data = {}
    for i in range(0, (len(link_elements)) - 2):
        title = link_elements[i].text
        location = location_elements[i].text
        image = image_sources[i]

        lat_offset = random.uniform(-0.002, 0.002)
        lon_offset = random.uniform(-0.002, 0.002)

        start_date = generate_random_date_week_ahead()
        end_date = start_date + timedelta(days=random.randint(6, 8)) #around 7 days.

        title = link_elements[i].text
        description = generate_event_description(title)
        
        id = str(uuid.uuid4()) 
        end_date = end_date.isoformat()

        event_data[id] = {
            "Latitude": 38.0356 + lat_offset,
            "Longitude": -78.5034 + lon_offset,
            "Upvotes": random.randint(0, 120),
            "Downvotes": random.randint(0, 40),
            "Participants": generate_random_participants(),
            "Categories": [get_random_event_type(), get_random_event_type()],
            "ContactEmail": generate_random_email(),
            "CreatedDate": datetime.now(timezone.utc).isoformat(),
            "Description": description,
            "EndDate": end_date,
            "ImageUrl": image,
            "Limit": random.randint(50, 200),
            "Organization": get_organization_name(title),
            "OrganizationOnly": False,
            "Publisher": generate_random_publisher(),
            "StartDate": start_date.isoformat(),
            "Title": title,
            "Location": location,
            "Date": start_date.isoformat(),
        }
        try:
            response = requests.post('http://127.0.0.1:8000/store-activity', json=create_simple_event_json(title, description, end_date, id))
            response.raise_for_status()
            print(f"Data sent successfully for event {title}. Response: {response.json()}")
        except requests.exceptions.RequestException as e:
            print(f"Failed to send data for event {title}: {e}")
    try:
        output_file_path = f"/flask/{output_file}"
        with open(output_file_path, 'w') as json_file:
            json.dump(event_data, json_file, indent=4)
        print(f"Event data written to {output_file_path}")
    except IOError as e:
        print(f"Error writing to file {output_file}: {e}")

def get_random_event_type():
    event_types = [
        "Academic", "Admissions", "Athletics", "Ceremony", "Conference",
        "Exhibit", "Information Session", "Lectures & Seminars", "Meeting",
        "Performance", "Screening", "Special Event", "Student Activity", "Workshop"
    ]
    return random.choice(event_types)

def generate_random_publisher():
    publishers = [
        "University Events", "Student Activities Board", "Academic Departments",
        "Athletics Department", "Community Outreach", "Cultural Center",
        "Library Services", "Alumni Association", "Performing Arts Group",
        "Research Institute", "Campus Recreation", "Admissions Office",
        "Faculty Association", "Graduate School", "Undergraduate Studies"
    ]
    return random.choice(publishers)


def main():
    """Main function to run the scraping and JSON generation continuously."""
    while True:
        scrape()


if __name__ == "__main__":
    main()