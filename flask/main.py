from flask import Flask, request, jsonify 
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask_cors import CORS

app = Flask(__name__)

# Enable CORS for all routes
CORS(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
collection = db.collection("message")
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
    activities = []  # Convert each document to a dictionary

    for doc in docs:
        activity = doc.to_dict()
        activity["weight"] = 5 # Calculate weight based on user location
        activities.append(activity)

    return {"activities": activities}  # Return the list of activities as a JSON response

def get_weight(user_latitude, user_longitude, ):
    return user_latitude - user_longitude 


if __name__ == '__main__':
    app.run(port=8000, debug=True)