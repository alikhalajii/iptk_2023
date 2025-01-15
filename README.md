# IPTK_Praktikum, Summer Term 2023  
**spaceXchange**, P2P Parking Spot Sharing App  


## Installation  

You can either use the deliverables/spaceXchange.apk or follow the steps below to set up and run the app:  

### Prerequisites  
1. [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.  
2. A Google Cloud project with the Google Maps API enabled ([Guide](https://developers.google.com/maps/documentation/embed/get-api-key)).  

### Steps  

1. **Generate API Key**  
   Create a Google Maps API key and enable the following APIs in your Google Cloud Console:  
   - Maps SDK for Android/iOS  
   - Geocoding API  
   - Places API  

2. **Add API Key to Project**  
   - Open the file at `myapp/lib/mapPages/api_keys.dart`.  
   - Add your API key like this:  
     ```dart
     const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
     ```  

3. **Run the App**  
   Fetch dependencies and build the app:  
   ```bash
   flutter pub get  
   flutter run  
