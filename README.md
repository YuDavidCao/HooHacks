# HooHacks
## This project is for the 2025 Hoo Hacks event 

## Python Setup

### Prerequisites
- Node.js: can be installed [here](https://nodejs.org/en)

### Change directory to flask 
This command changes your directory to the flask folder: 
```
cd flask
```

### Create virtual environment in flask directory
If on Mac: 
```
python3 -m venv venv
``` 
If on Windows: 
python -m venv venv 

### Run virtual enviornment
Run the command below to activate the virtual environment
```
source venv/bin/activate 
``` 
Ensure that your python interpretor is set for that virtual environment using ctrl+shift+p or cmd+shift+p 


### Install dependencies 
Run this command to install the proper dependencies 
```
pip install -r requirements.txt 
```

### Set up Gemini support 
create .env file in root directory. Paste the following and replace "YOUR_KEY" with your gemini_api_key. 
```
GEMINI_API_KEY="YOUR_KEY"
```

## ChromaDb Setup

### Prerequisites

docker pull chromadb:

```
docker run -v ./chroma-data:/data -p 4000:8000 chroma-core/chroma
```

Make sure that the port matches

## Flutter Setup

### Prerequisites
- Make sure you have Flutter installed. All development is done on IOS simulator, additional setup are required for Android for packages like google_maps_flutter.
