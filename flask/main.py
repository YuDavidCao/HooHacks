from flask import Flask, request, jsonify 
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask_cors import CORS
import datetime 

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
collection = db.collection("message")
users_collection = db.collection("users")

@app.route('/get-messages', methods=['GET'])
def get_messages():
    docs = collection.get()
    messages = [doc.to_dict() for doc in docs]
    return {"messages": messages}

@app.route('/create-activity', methods=['POST'])
def get_activities():
    data = request.json
    activity = {
        "Publisher": data.get("Publisher"),
        "Title": data.get("Title"),
        "Description": data.get("Description"),
        "CreatedDate": datetime.utcnow(),
        "StartDate": datetime.strptime(data["StartDate"], "%Y-%m-%dT%H:%M:%S") if "StartDate" in data else None,
        "EndDate": datetime.strptime(data["EndDate"], "%Y-%m-%dT%H:%M:%S") if "EndDate" in data else None,
        "Latitude": float(data["Latitude"]) if "Latitude" in data else None,
        "Longitude": float(data["Longitude"]) if "Longitude" in data else None,
        "Organization": data.get("Organization"),
        "Categories": data.get("Categories", []),
        "Participants": data.get("Participants", []),
        "Limit": data.get("Limit"),
        "ContactEmail": data.get("ContactEmail"),
        "Upvotes": int(data.get("Upvotes", 0)),
        "Downvotes": int(data.get("Downvotes", 0)),
        "OrganizationOnly": bool(data.get("OrganizationOnly", False))
    }
    
    doc_ref = collection.add(activity)
    doc = doc_ref[1].get().to_dict() 
    
    return {"activity": doc}, 201 


@app.route('/get-users', methods=['GET'])
def get_users():
    #docs = users_collection.document(uid).get()
    #return docs.to_dict()
    #doc = users_collection.document(uid).get()
    #if doc.exists:
    #    return jsonify(doc.to_dict()), 200
    #else:
    #    return jsonify({'error': 'User not found'}), 404
    docs = users_collection.stream()
    users = [doc.to_dict() for doc in docs]
    return jsonify({"users": users}), 200

if __name__ == '__main__':
    app.run(debug=True, threaded=True, port=5000)