/// Firebase configuration for the CCE Navigation app.
///
/// SETUP INSTRUCTIONS:
/// 1. Go to Firebase Console: https://console.firebase.google.com/
/// 2. Create a new project or select existing one
/// 3. Go to Project Settings → Your apps → Web app
/// 4. Copy the config values and paste them below
class FirebaseConfig {
  FirebaseConfig._();

  // TODO: Replace these with your actual Firebase config values
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String authDomain = 'YOUR_PROJECT_ID.firebaseapp.com';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String storageBucket = 'YOUR_PROJECT_ID.appspot.com';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String appId = 'YOUR_APP_ID';

  /// Storage bucket URL for panoramic images
  static String get panoramaStorageUrl =>
      'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/panoramas%2F';

  /// Gets the full URL for a panoramic image
  static String getPanoramaUrl(String imageId) {
    return '$panoramaStorageUrl$imageId?alt=media';
  }
}
