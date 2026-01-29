/// Supabase configuration for panoramic image storage.
///
/// SETUP INSTRUCTIONS:
/// 1. Go to https://supabase.com
/// 2. Create a new project
/// 3. Go to Settings → API
/// 4. Copy the Project URL and anon/public key
/// 5. Paste them below
class SupabaseConfig {
  SupabaseConfig._();

  // TODO: Replace with your Supabase project values
  // Get these from: Settings → API in Supabase dashboard
  static const String projectUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY_HERE';

  /// Storage bucket name for panoramic images
  static const String panoramaBucket = 'panoramas';

  /// Gets the full URL for a panoramic image
  static String getPanoramaUrl(String imageFileName) {
    return '$projectUrl/storage/v1/object/public/$panoramaBucket/$imageFileName';
  }

  /// Gets the upload URL for the Supabase storage bucket
  static String get uploadUrl =>
      '$projectUrl/storage/v1/object/$panoramaBucket';
}
