import firebase_admin
from firebase_admin import credentials, db
from firebase_admin import firestore
import random
from datetime import datetime, timedelta
import secrets
import string

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json") 
firebase_admin.initialize_app(cred)
db = firestore.client()

# Clark Hall coordinates (UVA)
base_lat = 38.0336
base_lng = -78.5070

# Provided category list
categories_list = [
  "Academic", "Admissions", "Athletics", "Ceremony", "Conference",
  "Exhibit", "Information Session", "Lectures & Seminars", "Meeting",
  "Performance", "Screening", "Special Event", "Student Activity",
  "Workshop", "1st Year", "2nd Year", "3rd Year", "4th Year", "Graduate"
]

# Generate fake email
def random_email():
    domains = ["virginia.edu", "gmail.com", "outlook.com"]
    name = ''.join(random.choices(string.ascii_lowercase, k=8))
    return f"{name}@{random.choice(domains)}"

def generate_random_id(length=20):
    return ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(length))

def generate_mock_data():
    data = {}
    # for i in range(1, 10):
    #     group_key = f"group{i}"

    #     num_participants = random.randint(0, 1000)

    #     # Each participant has a random value (could be score, ID, etc.)
    #     participants_list = ["a", "b", "c", "d"]
    for _ in range(9):  # Create 6 groups
        group_key = generate_random_id()
        num_participants = random.randint(0, 1000)
        participants_list = [f"user_{j}" for j in range(num_participants)]

        # Votes must not exceed the number of participants
        upvotes = random.randint(0, num_participants)
        downvotes = random.randint(0, num_participants - upvotes)

        now = datetime.utcnow()
        start_date = now
        end_date = now + timedelta(days=1)
        created_date = now

        data[group_key] = {
            "Latitude": round(base_lat + random.uniform(-0.0015, 0.0015), 6),
            "Longitude": round(base_lng + random.uniform(-0.0015, 0.0015), 6),
            "Upvotes": upvotes,
            "Downvotes": downvotes,
            "Participants": participants_list,

            # Extra static fields
            "Categories": [random.choice(categories_list)],
            "ContactEmail": random_email(),
            "CreatedDate": created_date,
            "Description": f"A fun and insightful event about {random.choice(categories_list).lower()} happening soon!",
            "EndDate": end_date,
            "ImageUrl": None,
            "Limit": None,
            "Organization": None,
            "OrganizationOnly": random.choice([True, False]),
            "Publisher": f"publisher_{generate_random_id(8)}",
            "StartDate": start_date,
            "Title": f"{random.choice(categories_list)} Event #{random.randint(1, 10)}"
        }
    return data

# Generate and upload to Firestore
data = generate_mock_data()
for group_name, doc_data in data.items():
    db.collection("activities").document(group_name).set(doc_data)


print("Data successfully uploaded to Firestore")