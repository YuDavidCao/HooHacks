import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

# Initialize Firebase
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load the events from your JSON file
with open("events.json") as f:
    events = json.load(f)

# Convert string timestamps to datetime objects
def parse_timestamp(value):
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return value
    return value

# Upload each event to the Firestore "activities" collection
for event_id, event_data in events.items():
    for key in ["CreatedDate", "StartDate", "EndDate"]:
        if key in event_data:
            event_data[key] = parse_timestamp(event_data[key])

    db.collection("activities").document(event_id).set(event_data)
    print(f"✅ Uploaded: {event_id}")

print("🎉 All events from activities_test.json uploaded to Firestore!")
