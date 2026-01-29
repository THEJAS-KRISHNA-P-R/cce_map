# Next Steps: Upload Your Panoramic Images

## Your Configuration
✅ **GitHub Repository**: `https://github.com/THEJAS-KRISHNA-P-R/cce-images`
✅ **GitHub Pages URL**: `https://thejas-krishna-p-r.github.io/cce-images/`
✅ **App Configured**: Ready to load images from GitHub Pages

---

## Step 1: Enable GitHub Pages (2 minutes)

1. Go to your repo: https://github.com/THEJAS-KRISHNA-P-R/cce-images
2. Click **Settings** (⚙️ icon at top)
3. Scroll down to **"Pages"** in left sidebar
4. Under **"Source"**:
   - **Branch**: Select `main` (or `master`)
   - **Folder**: Select `/ (root)`
5. Click **"Save"**
6. Wait 1-2 minutes - you'll see: "Your site is live at https://thejas-krishna-p-r.github.io/cce-images/"

---

## Step 2: Upload Your Panoramic Images

### Option A: GitHub Web Interface (Easiest)

1. Go to: https://github.com/THEJAS-KRISHNA-P-R/cce-images
2. Click **"Add file"** → **"Create new file"**
3. In the filename box, type: `panoramas/test.webp` (this creates the folder)
4. Click **"Cancel"** (we just wanted to create the folder structure)
5. Now click **"Add file"** → **"Upload files"**
6. Drag and drop your panoramic images
7. Click **"Commit changes"**

### Option B: Git Command Line (For Many Images)

```bash
# Clone your repository
git clone https://github.com/THEJAS-KRISHNA-P-R/cce-images.git
cd cce-images

# Create panoramas folder
mkdir panoramas
cd panoramas

# Copy your images here from Google Drive
# Then commit and push
cd ..
git add panoramas/
git commit -m "Add panoramic images"
git push origin main
```

---

## Step 3: Organize Your Images

Create this folder structure in your repo:

```
cce-images/
├── README.md
└── panoramas/
    ├── main_entrance.webp
    ├── library.webp
    ├── cafeteria.webp
    ├── classroom_101.webp
    └── ... (all your panoramic images)
```

**Image Naming Tips:**
- Use lowercase
- Use underscores instead of spaces
- Be descriptive
- Examples:
  - ✅ `main_entrance.webp`
  - ✅ `library_reading_room.webp`
  - ❌ `IMG_001.jpg`

---

## Step 4: Test Your Setup

After uploading images, test if they're accessible:

1. Wait 2-3 minutes for GitHub Pages to update
2. Open this URL in your browser (replace with your actual image name):
   ```
   https://thejas-krishna-p-r.github.io/cce-images/panoramas/test.webp
   ```
3. If the image loads, you're good to go! ✅

---

## Step 5: Link Images to Nodes

Now add panoramic images to your navigation nodes in the GeoJSON file.

**Example Node with Panorama:**

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
    "accessible": true,
    "floor": 0,
    "name": "Main Entrance",
    "panoUrl": "main_entrance.webp"
  }
}
```

**Important:** The `panoUrl` should be just the filename (e.g., `main_entrance.webp`), not the full URL. The app will automatically construct the full GitHub Pages URL.

---

## Step 6: Test in Your App

1. Make sure your app is running:
   ```bash
   flutter run -d chrome
   ```

2. Enable admin mode (if needed)

3. Click on a node that has a `panoUrl`

4. The panoramic viewer should open with your image! 🎉

5. Navigation arrows will appear for connected nodes

---

## Example: Complete Workflow

### 1. Upload Image to GitHub
- File: `panoramas/library.webp`
- Commit and push

### 2. Wait for GitHub Pages
- Wait 2-3 minutes
- Test URL: `https://thejas-krishna-p-r.github.io/cce-images/panoramas/library.webp`

### 3. Add to GeoJSON
```json
{
  "id": "library_entrance",
  "properties": {
    "panoUrl": "library.webp",
    "name": "Library Entrance"
  }
}
```

### 4. Save and Test
- Click the Save button (💾) in admin mode
- Click the node on the map
- Panorama opens!

---

## Troubleshooting

### Images not loading?
1. ✅ Check GitHub Pages is enabled (Settings → Pages)
2. ✅ Wait 2-3 minutes after uploading
3. ✅ Verify image is in `panoramas` folder
4. ✅ Check filename matches exactly in GeoJSON
5. ✅ Test the direct URL in browser

### 404 Error?
- Check spelling of filename (case-sensitive!)
- Ensure image was committed and pushed
- Verify folder structure is correct

### Slow loading?
- Compress images before upload
- Use WebP format instead of JPEG
- Reduce resolution to 2048x1024

---

## Image Optimization Tips

### Convert to WebP (Smaller Size)
```bash
# Using ImageMagick
magick input.jpg -quality 85 output.webp

# Batch convert all JPEGs
for file in *.jpg; do
  magick "$file" -quality 85 "${file%.jpg}.webp"
done
```

### Resize Images
```bash
# Resize to recommended size
magick input.jpg -resize 4096x2048 output.webp
```

---

## Your URLs

**Repository**: https://github.com/THEJAS-KRISHNA-P-R/cce-images

**GitHub Pages**: https://thejas-krishna-p-r.github.io/cce-images/

**Image URL Format**: 
```
https://thejas-krishna-p-r.github.io/cce-images/panoramas/IMAGE_NAME.webp
```

**Example**:
- Upload: `panoramas/library.webp`
- URL: `https://thejas-krishna-p-r.github.io/cce-images/panoramas/library.webp`
- In GeoJSON: `"panoUrl": "library.webp"`

---

## Ready to Upload!

1. ✅ Enable GitHub Pages in your repo settings
2. ✅ Upload images to `panoramas` folder
3. ✅ Wait 2-3 minutes
4. ✅ Test image URLs in browser
5. ✅ Add `panoUrl` to nodes in GeoJSON
6. ✅ Test in your app
7. 🎉 Enjoy your Street View feature!

---

**Need help?** Check the full guide in `GITHUB_PAGES_SETUP.md`
