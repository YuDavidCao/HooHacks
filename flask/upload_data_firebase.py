import firebase_admin
from firebase_admin import credentials, db
from firebase_admin import firestore
import random
from datetime import datetime, timedelta

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json") 
firebase_admin.initialize_app(cred)
db = firestore.client()

# Clark Hall coordinates (UVA)
base_lat = 38.0336
base_lng = -78.5070

def generate_mock_data():
    data = {}
    for i in range(1, 10):
        group_key = f"group{i}"

        num_participants = random.randint(0, 1000)

        # Each participant has a random value (could be score, ID, etc.)
        participants_list = ["a", "b", "c", "d"]

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
            "Categories": ["Lectures & Seminars"],
            "ContactEmail": "example@uva.edu",
            "CreatedDate": created_date,
            "Description": f"Sample description for group {i}",
            "EndDate": end_date,
            "ImageUrl": None,
            "Limit": None,
            "Organization": None,
            "OrganizationOnly": False,
            "Publisher": f"publisher_{i}",
            "StartDate": start_date,
            "Title": f"Event Title {i}"
        }
    return data

# Generate and upload to Firestore
data = generate_mock_data()
for group_name, doc_data in data.items():
    db.collection("activities").document(group_name).set(doc_data)


print("Data successfully uploaded to Firestore")