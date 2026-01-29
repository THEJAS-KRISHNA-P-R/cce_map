/// GitHub Pages configuration for panoramic images.
///
/// SETUP INSTRUCTIONS:
/// 1. Create a public GitHub repository (e.g., "cce-panoramas")
/// 2. Enable GitHub Pages in repo Settings → Pages
/// 3. Upload your panoramic images to a "panoramas" folder
/// 4. Update the username and repoName below
/// 5. Your images will be at: https://username.github.io/reponame/panoramas/image.webp
class GitHubConfig {
  GitHubConfig._();

  // Your GitHub repository details
  static const String username = 'THEJAS-KRISHNA-P-R';
  static const String repoName = 'cce-images';

  /// Base URL for GitHub Pages
  static String get baseUrl => 'https://$username.github.io/$repoName';

  /// Folder name where panoramic images are stored
  static const String panoramaFolder = 'panoramas';

  /// Gets the full URL for a panoramic image
  ///
  /// Example:
  /// ```dart
  /// GitHubConfig.getPanoramaUrl('library.webp')
  /// // Returns: https://username.github.io/cce-panoramas/panoramas/library.webp
  ///
  /// GitHubConfig.getPanoramaUrl('https://example.com/image.jpg')
  /// // Returns: https://example.com/image.jpg (passed through as-is)
  /// ```
  static String getPanoramaUrl(String imageFileName) {
    if (imageFileName.startsWith('http')) {
      // Auto-fix GitHub blob URLs to raw URLs
      if (imageFileName.contains('github.com') &&
          imageFileName.contains('/blob/')) {
        return imageFileName
            .replaceFirst('github.com', 'raw.githubusercontent.com')
            .replaceFirst('/blob/', '/');
      }
      return imageFileName;
    }
    // Handle user's nested structure - if it contains slashes, don't prepend 'panoramas' again if not needed
    // But for now, let's keep it simple: if it's a filename, use the standard path
    return '$baseUrl/$panoramaFolder/$imageFileName';
  }

  /// Gets the URL for an image in a subfolder
  ///
  /// Example:
  /// ```dart
  /// GitHubConfig.getPanoramaUrlWithPath('ground_floor/lobby.webp')
  /// // Returns: https://username.github.io/cce-panoramas/panoramas/ground_floor/lobby.webp
  /// ```
  static String getPanoramaUrlWithPath(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$baseUrl/$panoramaFolder/$imagePath';
  }
}
