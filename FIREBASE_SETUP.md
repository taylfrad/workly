# Firebase Configuration Setup

To enable Google Sign-In functionality, you'll need to set up Firebase for your Flutter app.

## Steps to Configure Firebase:

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Follow the setup wizard

### 2. Add Your App to Firebase

1. In the Firebase Console, click "Add app" and select Flutter
2. Follow the setup instructions to add your app
3. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 3. Configure Web App (Required for Chrome testing)

1. In Firebase Console, click "Add app" and select **Web** (</> icon)
2. Register your web app with nickname "Workly Web"
3. Copy the Firebase configuration object
4. Update `web/index.html` with your actual Firebase config values:
   ```javascript
   const firebaseConfig = {
     apiKey: "your-actual-api-key",
     authDomain: "your-project-id.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project-id.appspot.com",
     messagingSenderId: "your-sender-id",
     appId: "your-app-id",
   };
   ```

### 4. Enable Authentication

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable "Google" as a sign-in provider
3. Add your app's SHA-1 fingerprint (for Android)

### 4. Configure Google Sign-In

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Enable the Google+ API
4. Configure OAuth consent screen if needed

### 5. Update Dependencies

The required dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
  provider: ^6.1.2
```

### 4. Configure Google Sign-In

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Enable the Google+ API
4. Configure OAuth consent screen if needed

### 5. Update Dependencies

```bash
flutter pub get
flutter run
```

## Features Implemented:

✅ **Google Sign-In**: Users can sign in with their Google account  
✅ **Guest Mode**: Users can continue without signing in  
✅ **User State Management**: Proper authentication state handling  
✅ **Profile Persistence**: Signed-in users' profiles are saved  
✅ **Sign Out**: Users can sign out from their account  
✅ **Error Handling**: Proper error messages for failed authentication

## User Flow:

1. **Auth Screen**: Users see two options:

   - "Sign in with Google" - Full account with saved progress
   - "Continue as Guest" - Temporary session without saved progress

2. **Profile Screen**:

   - Guest users see a notice about limited functionality
   - Signed-in users can sign out via the app bar
   - Both can complete their profile and start swiping

3. **Job Swipe Screen**: Both user types can swipe on jobs, but only signed-in users will have their preferences saved.

## Notes:

- Guest users get a unique temporary ID
- Signed-in users get their Google profile information pre-filled
- All authentication state is managed through the `AuthProvider`
- The app handles authentication state changes automatically
