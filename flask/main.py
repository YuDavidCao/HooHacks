from flask import Flask
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
collection = db.collection("message")

@app.route('/get-messages', methods=['GET'])
def get_messages():
    docs = collection.get()
    messages = [doc.to_dict() for doc in docs]
    return {"messages": messages}
    

if __name__ == '__main__':
    app.run(debug=True, threaded=True, port=5000)