import chromadb

# Initialize ChromaDB client
client = chromadb.Client()

# Collection name
collection_name = "activity_embeddings"

# Check if the collection exists, if not, create it
try:
    collection = client.get_collection(collection_name)
    print(f"Collection '{collection_name}' exists.")
except chromadb.errors.InvalidCollectionException:
    # Create a new collection if it doesn't exist
    print(f"Collection '{collection_name}' does not exist. Creating it now.")
    collection = client.create_collection(collection_name)