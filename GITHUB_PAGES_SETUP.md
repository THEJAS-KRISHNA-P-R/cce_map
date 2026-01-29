# GitHub Pages Setup for Panoramic Images

## Why GitHub Pages?
- ✅ **Completely FREE** - No credit card, no limits
- ✅ **Unlimited storage** for public repos
- ✅ **Unlimited bandwidth** via GitHub CDN
- ✅ **Fast global CDN** - Images load quickly worldwide
- ✅ **Version control** - Track changes to your images
- ✅ **Easy to update** - Just push new images

---

## Step 1: Create GitHub Repository (3 minutes)

1. Go to [https://github.com](https://github.com)
2. Sign in (or create account if needed)
3. Click **"New repository"** (green button)
4. Fill in:
   - **Repository name**: `cce-panoramas`
   - **Description**: `Panoramic images for CCE Navigation`
   - **Public**: ✅ **Must be public** (required for GitHub Pages)
   - **Add README**: ✅ Check this box
5. Click **"Create repository"**

---

## Step 2: Enable GitHub Pages (1 minute)

1. In your new repo, click **Settings** (⚙️ icon)
2. Scroll down to **"Pages"** in left sidebar
3. Under **"Source"**, select:
   - **Branch**: `main`
   - **Folder**: `/ (root)`
4. Click **"Save"**
5. Wait 1-2 minutes for deployment
6. Your site will be at: `https://YOUR_USERNAME.github.io/cce-panoramas/`

---

## Step 3: Upload Your Panoramic Images

### Option A: Web Interface (Easy for few images)

1. In your repo, click **"Add file"** → **"Upload files"**
2. Create folder structure:
   ```
   panoramas/
   ├── ground_floor/
   │   ├── main_entrance.webp
   │   └── lobby.webp
   ├── first_floor/
   │   └── library.webp
   └── outdoor/
       └── parking.webp
   ```
3. Drag and drop your images
4. Click **"Commit changes"**

### Option B: Git CLI (Best for many images)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/cce-panoramas.git
cd cce-panoramas

# Create panoramas folder
mkdir panoramas
cd panoramas

# Copy your images here
# (copy from your Google Drive folder)

# Add and commit
git add .
git commit -m "Add panoramic images"
git push origin main
```

### Option C: GitHub Desktop (Easiest)

1. Download [GitHub Desktop](https://desktop.github.com/)
2. Clone your `cce-panoramas` repo
3. Copy your images into the `panoramas` folder
4. Commit and push in GitHub Desktop

---

## Step 4: Get Your Image URLs

After uploading, your images will be available at:

```
https://YOUR_USERNAME.github.io/cce-panoramas/panoramas/IMAGE_NAME.webp
```

**Example:**
- Repo: `https://github.com/john/cce-panoramas`
- Image: `panoramas/library.webp`
- **URL**: `https://john.github.io/cce-panoramas/panoramas/library.webp`

---

## Step 5: Configure Your Flutter App

Create `lib/core/config/github_config.dart`:

```dart
/// GitHub Pages configuration for panoramic images.
class GitHubConfig {
  GitHubConfig._();

  // TODO: Replace with your GitHub username and repo name
  static const String username = 'YOUR_GITHUB_USERNAME';
  static const String repoName = 'cce-panoramas';
  
  /// Base URL for GitHub Pages
  static String get baseUrl => 'https://$username.github.io/$repoName';
  
  /// Gets the full URL for a panoramic image
  static String getPanoramaUrl(String imageFileName) {
    return '$baseUrl/panoramas/$imageFileName';
  }
}
```

---

## Step 6: Update Navigation Provider

Edit `lib/providers/navigation_provider.dart`:

```dart
import '../core/config/github_config.dart';

// In getPanoramaUrl method:
String? getPanoramaUrl(String nodeId) {
  final node = getNode(nodeId);
  if (node?.panoUrl == null) return null;
  
  return GitHubConfig.getPanoramaUrl(node!.panoUrl!);
}
```

---

## Step 7: Link Images to Nodes

In your GeoJSON file (`assets/data/cce_test.geojson`):

```json
{
  "type": "Feature",
  "id": "main_entrance",
  "geometry": {
    "type": "Point",
    "coordinates": [76.2127, 10.3575]
  },
  "properties": {
    "type": "entrance",
    "panoUrl": "main_entrance.webp",
    "name": "Main Entrance",
    "floor": 0
  }
}
```

---

## Image Requirements

### Format
- **WebP** (recommended): Smaller file size, better quality
- **JPEG**: Widely supported, good compatibility

### Size
- **Recommended**: 4096x2048 pixels (equirectangular)
- **Minimum**: 2048x1024 pixels
- **Maximum**: 8192x4096 pixels (may be slow to load)

### Naming Convention
- Use lowercase
- Use underscores instead of spaces
- Be descriptive
- Examples:
  - ✅ `main_entrance.webp`
  - ✅ `library_reading_room.webp`
  - ✅ `cafeteria_inside.webp`
  - ❌ `IMG_001.jpg`
  - ❌ `photo 1.jpeg`

---

## Folder Structure Example

```
cce-panoramas/
├── README.md
└── panoramas/
    ├── ground_floor/
    │   ├── main_entrance.webp
    │   ├── lobby.webp
    │   ├── reception.webp
    │   └── cafeteria.webp
    ├── first_floor/
    │   ├── library_entrance.webp
    │   ├── library_reading.webp
    │   ├── classroom_101.webp
    │   └── corridor_east.webp
    ├── second_floor/
    │   ├── lab_computer.webp
    │   └── lab_physics.webp
    └── outdoor/
        ├── parking_main.webp
        ├── garden.webp
        └── sports_ground.webp
```

---

## Testing Your Setup

1. Upload one test image to GitHub
2. Wait 1-2 minutes for GitHub Pages to update
3. Test the URL in your browser:
   ```
   https://YOUR_USERNAME.github.io/cce-panoramas/panoramas/test.webp
   ```
4. If it loads, you're good to go!
5. Add the image to a node in your GeoJSON
6. Run your app and test

---

## Updating Images

### Add New Images
```bash
cd cce-panoramas
# Add new images to panoramas folder
git add panoramas/
git commit -m "Add new panoramic images"
git push
```

### Replace Images
Just overwrite the file and push:
```bash
# Replace old image with new one (same filename)
git add panoramas/library.webp
git commit -m "Update library panorama"
git push
```

### Delete Images
```bash
git rm panoramas/old_image.webp
git commit -m "Remove old image"
git push
```

---

## Advantages of GitHub Pages

1. **Free Forever**: No hidden costs, no credit card
2. **Unlimited Storage**: Upload as many images as you need
3. **Fast CDN**: GitHub's global CDN ensures fast loading
4. **Version Control**: Track all changes to your images
5. **Easy Updates**: Just push new images via Git
6. **Reliable**: GitHub's 99.9% uptime guarantee
7. **No Bandwidth Limits**: Serve unlimited image views

---

## Disadvantages (Minor)

1. **Public Only**: Images must be in a public repo
2. **Git Learning Curve**: Need basic Git knowledge
3. **2-minute Delay**: Changes take 1-2 minutes to deploy
4. **100GB Repo Limit**: (You won't hit this with images)

---

## Pro Tips

### Optimize Images Before Upload
```bash
# Install ImageMagick
# Convert to WebP and resize
magick input.jpg -resize 4096x2048 -quality 85 output.webp
```

### Batch Convert Images
```bash
# Convert all JPEGs to WebP
for file in *.jpg; do
  magick "$file" -quality 85 "${file%.jpg}.webp"
done
```

### Check Image Size
```bash
# Keep images under 5MB for fast loading
ls -lh panoramas/
```

---

## Troubleshooting

### Images not loading?
1. ✅ Check repo is **public**
2. ✅ Verify GitHub Pages is enabled
3. ✅ Wait 2-3 minutes after pushing
4. ✅ Check URL is correct (case-sensitive)
5. ✅ Clear browser cache

### 404 Error?
- Verify the file path matches exactly
- Check for typos in filename
- Ensure file was committed and pushed

### Slow Loading?
- Reduce image size (2048x1024 instead of 4096x2048)
- Convert to WebP format
- Compress images before upload

---

## Example: Complete Setup

**1. Your GitHub repo:**
```
https://github.com/john/cce-panoramas
```

**2. Image uploaded:**
```
panoramas/library.webp
```

**3. GitHub Pages URL:**
```
https://john.github.io/cce-panoramas/panoramas/library.webp
```

**4. In your code:**
```dart
GitHubConfig.getPanoramaUrl('library.webp')
// Returns: https://john.github.io/cce-panoramas/panoramas/library.webp
```

**5. In your GeoJSON:**
```json
{
  "properties": {
    "panoUrl": "library.webp"
  }
}
```

---

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Enable GitHub Pages
3. ✅ Upload test image
4. ✅ Verify URL works in browser
5. ✅ Update `github_config.dart`
6. ✅ Test in your app
7. ✅ Upload all panoramic images
8. ✅ Link images to nodes in GeoJSON
9. 🎉 Enjoy your free Street View feature!

---

**Ready to start?** Create your repo at [github.com/new](https://github.com/new)!
