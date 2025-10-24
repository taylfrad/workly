# Firebase Configuration Setup

## Security Notice

This repository has been configured to prevent Firebase API keys from being committed to version control. The following files contain sensitive information and should NOT be committed:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## Setup Instructions

### 1. Generate Firebase Configuration Files

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `workly-cbf7d`
3. Generate new configuration files:

#### For Android:

1. Go to Project Settings > General > Your apps
2. Select your Android app
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### For iOS:

1. Go to Project Settings > General > Your apps
2. Select your iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 2. Generate Firebase Options Dart File

1. Install FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:

   ```bash
   flutterfire configure
   ```

3. This will generate `lib/firebase_options.dart` with your actual configuration

### 3. Verify Setup

After completing the setup, verify that:

- All three files are present in your local project
- None of these files appear in `git status` (they should be ignored)
- Your app builds and connects to Firebase successfully

## Important Security Notes

- **Never commit** the actual configuration files to version control
- **Rotate your API keys** immediately if they were previously exposed
- Use the template file `lib/firebase_options_template.dart` as a reference
- Consider using Firebase App Check for additional security

## If API Keys Were Previously Exposed

1. Go to Firebase Console > Project Settings > Service Accounts
2. Generate new API keys
3. Update your configuration files with the new keys
4. Monitor your Firebase usage for any unauthorized access

## Additional Security: Google OAuth Client ID

The Google OAuth client ID in `lib/services/auth_service.dart` (line 14) should also be rotated:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `workly-cbf7d`
3. Navigate to APIs & Services > Credentials
4. Find your OAuth 2.0 Client ID
5. Generate a new client ID
6. Update the `clientId` in `lib/services/auth_service.dart`

**Current exposed client ID:** `499488421543-dqpsq3vag3cus0hme6lohd7vj5cjes5i.apps.googleusercontent.com`
