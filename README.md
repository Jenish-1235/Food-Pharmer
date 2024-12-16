# Food Pharmer

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=white)
![Twitter API](https://img.shields.io/badge/Twitter_API-1DA1F2?logo=twitter&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=google-cloud&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## Overview

**Food Pharmer** is a Flutter-based mobile application designed to empower consumers with information about the ingredients in their food products. By leveraging image recognition and text extraction technologies, the app analyzes product labels to identify and highlight any potentially harmful ingredients. Additionally, Food Pharmer integrates with Twitter to automatically post warnings when unsafe ingredients are detected, promoting food safety awareness.

## Features

- **Image Capture & Upload:** Easily capture or select images of food product labels from your device.
- **Ingredient Analysis:** Utilizes Google Vision API to extract and analyze ingredient lists from images.
- **Harmful Ingredient Detection:** Compares extracted ingredients against a predefined database of harmful substances.
- **Real-Time Notifications:** Alerts users if any harmful ingredients are detected.
- **Automatic Tweeting:** Posts warnings on Twitter when unsafe ingredients are found, enhancing public awareness.
- **User Authentication:** Secure login and registration using Firebase Authentication.
- **Profile Management:** Users can manage their accounts and Twitter connections seamlessly.
- **Dashboard:** View a history of analyzed products and their safety status.

## Technologies Used

- **Flutter:** Front-end framework for building cross-platform mobile applications.
- **Dart:** Programming language used with Flutter.
- **Firebase Authentication:** Handles user authentication and secure access.
- **Google Cloud Platform (GCP):** Hosts the application backend and services.
- **Google Vision API:** Performs text extraction and image analysis.
- **Flutter Secure Storage:** Securely stores sensitive information like access tokens.
- **Twitter API v2:** Enables integration with Twitter for automated tweeting.
- **Cloud Firestore:** Database for storing and retrieving analysis results and ingredient data.

## Getting Started

Follow these instructions to set up and run the Food Pharmer app on your local machine.

### Prerequisites

- **Flutter SDK:** Ensure you have Flutter installed. [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Android Studio or VS Code:** Recommended IDEs for Flutter development.
- **Firebase Account:** Set up a Firebase project for authentication and Firestore.
- **Google Cloud Account:** Required for accessing the Google Vision API.
- **Twitter Developer Account:** Necessary for obtaining Twitter API credentials.

### Installation

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/your_username/food_pharmer.git
   cd food_pharmer
Install Dependencies:

sh
Copy code
flutter pub get
Set Up Firebase:

Add Firebase to Your Flutter Project: Follow the official guide to integrate Firebase Authentication and Firestore.
Download google-services.json and GoogleService-Info.plist: Place them in the respective directories as per Firebase setup instructions.
Configure Google Vision API:

Enable the API: In the Google Cloud Console, enable the Vision API for your project.
Obtain API Key: Generate an API key and add it to your Flutter project's configuration.
Set Up Twitter API:

Create a Twitter Developer App: Navigate to the Twitter Developer Portal and create a new application.
Obtain Credentials: Get your API Key, API Secret Key, Bearer Token, Client ID, and Client Secret.
Configure OAuth: Ensure your app has the necessary permissions and set up callback URLs if implementing OAuth flows.
Environment Variables:

Use flutter_dotenv: Manage your API keys and secrets securely.

Create a .env File:

env
Copy code
TWITTER_API_KEY=your_api_key
TWITTER_API_SECRET_KEY=your_api_secret_key
TWITTER_BEARER_TOKEN=your_bearer_token
GOOGLE_VISION_API_KEY=your_google_vision_api_key
Load Environment Variables in main.dart:

dart
Copy code
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
Run the App:

sh
Copy code
flutter run
Usage
Sign In:

Open the app and sign in using your Firebase credentials.
Connect Twitter Account:

Navigate to the Capture tab.
Tap on "Connect Twitter Account" to authorize the app to post tweets on your behalf.
Analyze a Product:

Capture an image using the camera or select one from your gallery.
Tap on "Analyze Image".
The app will extract text, identify ingredients, and compare them against the harmful ingredients database.
If harmful ingredients are detected, a warning tweet will be automatically posted.
View Dashboard:

Access the Dashboard tab to view a history of analyzed products and their safety status.
Manage Profile:

In the Profile tab, manage your account settings and disconnect your Twitter account if desired.
Contributing
We welcome contributions to enhance Food Pharmer! Please follow the guidelines below to contribute.

Steps to Contribute:
Fork the Repository:

Click the Fork button at the top right of this page to create your own copy of the repository.
Clone Your Fork:

sh
Copy code
git clone https://github.com/your_username/food_pharmer.git
cd food_pharmer
Create a New Branch:

sh
Copy code
git checkout -b feature/YourFeatureName
Make Your Changes:

Implement your feature or fix bugs as needed.
Commit Your Changes:

sh
Copy code
git commit -m "Add your descriptive commit message"
Push to Your Fork:

sh
Copy code
git push origin feature/YourFeatureName
Create a Pull Request:

Navigate to the original repository and create a pull request from your forked repository.
Guidelines:
Follow Code Standards: Ensure your code adheres to Flutter and Dart best practices.
Write Clear Commit Messages: Describe your changes succinctly.
Test Thoroughly: Ensure that your contributions do not break existing functionalities.
Credits
Food Pharmer is a collaborative project made possible by the dedicated efforts of the team members:

Anant Singh: Assisted in preparing and curating datasets essential for ingredient analysis.
Pratham Jain: Spearheaded the setup and configuration of Google Cloud Platform (GCP) services.
Shifa: Designed the user interface (UI) and user experience (UX), ensuring a seamless and intuitive app interaction.
Purab Ray: Implemented the integration with Twitter API, enabling automated tweeting functionalities.
Jenish Togadiya: Contributed to creating the Flutter application, overseeing the development and ensuring robust functionality.
We extend our gratitude to each contributor for their invaluable contributions to making Food Pharmer a reality!

License
This project is licensed under the MIT License.
