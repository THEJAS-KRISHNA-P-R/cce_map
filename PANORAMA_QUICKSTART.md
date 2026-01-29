# Quick Start: Adding Panoramic Images to Nodes

## TL;DR - 3 Steps to Get Started

### 1. Set Up Firebase (15 minutes)
```bash
# Go to https://console.firebase.google.com/
# Create project → Enable Storage → Upload images to "panoramas" folder
```

### 2. Configure App (2 minutes)
Edit `lib/core/config/firebase_config.dart`:
```dart
static const String storageBucket = 'your-project.appspot.com';
```

### 3. Link Images to Nodes
In your GeoJSON file, add `panoUrl` to nodes:
```json
{
  "properties": {
    "type": "entrance",
    "panoUrl": "main_entrance.webp",
    "name": "Main Entrance"
  }
}
```

## How It Works

### User Experience:
1. User taps a node on the map
2. Panoramic image opens in full-screen viewer
3. Interactive arrows show connected nodes
4. User clicks arrow → moves to next location
5. Map updates to show new position

### Image Requirements:
- **Format**: WebP or JPEG
- **Size**: 4096x2048px (or 2048x1024px for faster loading)
- **Type**: Equirectangular 360° panorama

## Upload Images to Firebase

### Quick Upload (Firebase Console):
1. Go to Firebase Console → Storage
2. Create folder: `panoramas`
3. Drag and drop your images
4. Done!

### Bulk Upload (Firebase CLI):
```bash
npm install -g firebase-tools
firebase login
gsutil -m cp -r ./your_images/* gs://YOUR_BUCKET/panoramas/
```

## Connect Images to Nodes

### Option A: Edit GeoJSON Directly
```json
{
  "type": "Feature",
  "id": "library_entrance",
  "properties": {
    "panoUrl": "library_front.webp"
  }
}
```

### Option B: Use Admin Mode
1. Enable admin mode
2. Select node
3. Add panorama URL in properties
4. Save changes

## Navigation Arrows

The app automatically creates clickable arrows for:
- All connected nodes (edges in your graph)
- Arrows point in the direction of connected nodes
- Click arrow → navigate to that node
- Your position updates on the map

## Full Guide

See `FIREBASE_SETUP.md` for complete instructions.

## Troubleshooting

**Images not showing?**
- Check Firebase Storage rules allow public read
- Verify image names match exactly
- Check browser console for errors

**Arrows not appearing?**
- Ensure nodes are connected (have edges)
- Check that connected nodes also have panoramic images

## Cost

Firebase free tier includes:
- 5GB storage
- 1GB/day downloads
- Perfect for campus navigation!

---

**Need help?** Check the full guide in `FIREBASE_SETUP.md`
