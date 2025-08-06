# Firebase Setup Guide for Workout App

This guide will help you set up Firebase for your Flutter workout app.

## Prerequisites

1. Flutter SDK installed
2. Firebase account
3. Android Studio / Xcode (for platform-specific setup)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "workout-app")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Add Android App

1. In your Firebase project, click the Android icon to add an Android app
2. Enter your Android package name: `com.example.workout_app`
3. Enter app nickname: "Workout App"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place the file in `android/app/google-services.json`

## Step 3: Add iOS App

1. In your Firebase project, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID: `com.example.workoutApp`
3. Enter app nickname: "Workout App"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the file in `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 5: Set up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 6: Set up Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select a location for your storage
5. Click "Done"

## Step 7: Update Configuration Files

### Update google-services.json
Replace the placeholder values in `android/app/google-services.json` with your actual Firebase project values:

```json
{
  "project_info": {
    "project_number": "YOUR_ACTUAL_PROJECT_NUMBER",
    "project_id": "your-actual-project-id",
    "storage_bucket": "your-actual-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_ACTUAL_MOBILE_SDK_APP_ID",
        "android_client_info": {
          "package_name": "com.example.workout_app"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_ACTUAL_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_ACTUAL_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "YOUR_ACTUAL_CLIENT_ID",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

### Update GoogleService-Info.plist
Replace the placeholder values in `ios/Runner/GoogleService-Info.plist` with your actual Firebase project values.

## Step 8: Install Dependencies

Run the following command to install all required dependencies:

```bash
flutter pub get
```

## Step 9: Initialize Sample Data

The app includes sample exercises that can be initialized in Firestore. You can do this by:

1. Running the app
2. Creating an admin account
3. Using the exercise service to initialize sample data

## Step 10: Test the Setup

1. Run the app: `flutter run`
2. Try to create an account
3. Verify that user data is stored in Firestore
4. Test authentication flow

## Security Rules

### Firestore Security Rules
Update your Firestore security rules in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can access their own workouts
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public exercises collection
    match /exercises/{exerciseId} {
      allow read: if true;
      allow write: if false; // Only admins should write
    }
  }
}
```

### Storage Security Rules
Update your Storage security rules in the Firebase Console:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own profile images
    match /profile_images/{fileName} {
      allow read, write: if request.auth != null && 
        fileName.matches('profile_' + request.auth.uid + '_.*');
    }
    
    // Users can upload their own workout images
    match /workout_images/{userId}/{fileName} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
    
    // Public exercise images
    match /exercise_images/{fileName} {
      allow read: if true;
      allow write: if false; // Only admins should write
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Build errors**: Make sure all configuration files are in the correct locations
2. **Authentication errors**: Verify that Email/Password authentication is enabled
3. **Database errors**: Check Firestore security rules
4. **Storage errors**: Check Storage security rules

### Debug Mode

For development, you can use test mode in Firestore and Storage, but remember to update the security rules before production.

## Production Considerations

1. Update security rules to be more restrictive
2. Enable additional authentication methods if needed
3. Set up proper backup strategies
4. Monitor usage and costs
5. Set up proper error tracking and analytics

## Support

If you encounter issues:
1. Check the Firebase documentation
2. Verify all configuration files are correct
3. Ensure all dependencies are properly installed
4. Check the Flutter and Firebase console logs 