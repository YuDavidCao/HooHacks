from flask import Flask, request, jsonify 
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask_cors import CORS
import math 
from datetime import datetime, timezone

app = Flask(__name__)

# Enable CORS for all routes
CORS(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
collection = db.collection("message")
users_collection = db.collection("users")
activities_collection = db.collection("activities")

@app.route('/get-messages', methods=['GET'])
def get_messages():
    docs = collection.get()
    messages = [doc.to_dict() for doc in docs]
    return {"messages": messages}

@app.route('/get-activity', methods=['POST'])
def get_activities():
    data = request.json
    if not data:
        return jsonify({"error": "Invalid request"}), 400

    user_id = data.get("Uid")
    user_latitude = float(data.get("Latitude"))
    user_longitude = float(data.get("Longitude"))

    docs = activities_collection.get()  # Fetch all documents from the "activity" collection
    activities = []  # Store filtered activities

    current_time = datetime.now(timezone.utc)  # Get current UTC time (timezone-aware)

    for doc in docs:
        activity = doc.to_dict()

        # Parse the EndDate from string to datetime
        end_date_str = activity.get("EndDate")
        if not end_date_str:
            continue  # Skip if EndDate is missing

        try:
            end_date = datetime.strptime(end_date_str, "%Y-%m-%dT%H:%M:%S.%f").replace(tzinfo=timezone.utc)
        except ValueError:
            continue  # Skip if EndDate format is incorrect

        # Filter out past activities
        if end_date < current_time:
            continue

        # Extract activity details
        latitude = activity.get("Latitude")
        longitude = activity.get("Longitude")
        participants = len(activity.get("Participants", []))
        downvotes = activity.get("Downvotes", 0)
        upvotes = activity.get("Upvotes", 0)

        # Calculate distance and weight
        distance = get_distance(user_latitude, user_longitude, latitude, longitude)
        activity["weight"] = get_weight(distance, participants, upvotes, downvotes)

        activities.append(activity)

    return jsonify({"activities": activities})  # Return the filtered list

def get_distance(user_latitude, user_longitude, activity_latitude, activity_longitude): # distance returned as kilometers
    user_latitude = math.radians(user_latitude)
    user_longitude = math.radians(user_longitude)
    activity_latitude = math.radians(activity_latitude)
    activity_longitude = math.radians(activity_longitude)

    # Haversine formula
    delta_lat = activity_latitude - user_latitude
    delta_lon = activity_longitude - user_longitude

    a = math.sin(delta_lat / 2)**2 + math.cos(user_latitude) * math.cos(activity_latitude) * math.sin(delta_lon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Earth's radius in kilometers (mean radius)
    R = 6371.0

    # Compute distance
    distance = R * c

    return distance

def get_weight(distance, participants, upvotes, downvotes):
    MAX_RELEVANT_DISTANCE = 3 # km (adjusted down from 100km)
    DISTANCE_WEIGHT = 0.5  # Increased because proximity is more important for local events
    PARTICIPANTS_WEIGHT = 0.2
    VOTES_WEIGHT = 0.3
    
    # Calculate distance score (closer = higher score)
    # With 5km being the typical range, use a steeper falloff curve
    if distance <= 0:  # Handle case where event is at user's location
        distance_score = 1.0
    else:
        # Exponential decay - events at 5km will get score of ~0.37
        distance_score = math.exp(-distance / 3.5)
    
    # Calculate participants score
    # Adjusted to give optimal scores in the 40-100 range
    # Handle None or non-numeric participants
    if participants is None or not isinstance(participants, (int, float)):
        participants = 0
        
    if participants <= 0:
        participants_score = 0.0
    elif participants <= 40:
        # Score rises linearly from 0 to 0.8 as participants go from 0 to 40
        participants_score = 0.8 * (participants / 40)
    elif participants <= 100:
        # Score rises from 0.8 to 1.0 as participants go from 40 to 100
        participants_score = 0.8 + 0.2 * ((participants - 40) / 60)
    else:
        # Score stays at 1.0 for events with over 100 participants
        participants_score = 1.0
    
    # Calculate vote score
    total_votes = upvotes + downvotes
    if total_votes == 0:
        vote_score = 0.5  # Neutral if no votes
    else:
        # Calculate base score from upvote ratio
        vote_ratio = upvotes / total_votes
        
        # Scale by volume - but with a cap to avoid excessive influence from very popular events
        vote_volume_factor = min(1.0, math.log10(total_votes + 1) / math.log10(51))  # Scales nicely up to 50 votes
        
        # Combine ratio and volume
        vote_score = 0.5 + (vote_ratio - 0.5) * vote_volume_factor
    
    # Combine scores using weights
    final_weight = (
        DISTANCE_WEIGHT * distance_score +
        PARTICIPANTS_WEIGHT * participants_score +
        VOTES_WEIGHT * vote_score
    )
    
    # Ensure the result is between 0 and 1
    return max(0, min(1, final_weight))


@app.route('/get-users', methods=['GET'])
def get_users():
    docs = users_collection.stream()
    users = [doc.to_dict() for doc in docs]
    return jsonify({"users": users}), 200

if __name__ == '__main__':
    app.run(port=8000, debug=True)