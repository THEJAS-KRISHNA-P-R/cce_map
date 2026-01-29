# Image URL Guide for Your Current Structure

## Your Current GitHub Structure

```
cce-images/
├── CCE MAP/
│   └── Outsides/
│       ├── Canteen to St.Marys/
│       ├── Main Gate to Chavara/
│       ├── St Mary_s through Forest route/
│       ├── St thomas to Christ hall/
│       ├── Techies Park/
│       ├── hostel jn nd parking lot mens hostel/
│       └── st marys front and main road to back gate and a bit of big ground/
```

---

## GitHub Pages URLs for Your Images

### Base URL:
```
https://thejas-krishna-p-r.github.io/cce-images/
```

### Full Image URLs (with current structure):

**For image in "Canteen to St.Marys" folder:**
```
https://thejas-krishna-p-r.github.io/cce-images/CCE%20MAP/Outsides/Canteen%20to%20St.Marys/image_name.webp
```

**For image in "Main Gate to Chavara" folder:**
```
https://thejas-krishna-p-r.github.io/cce-images/CCE%20MAP/Outsides/Main%20Gate%20to%20Chavara/image_name.webp
```

**Note:** Spaces become `%20` in URLs.

---

## How to Use in Your GeoJSON

### Option A: Using Current Nested Structure

In your GeoJSON, use the full path:

```json
{
  "properties": {
    "panoUrl": "CCE MAP/Outsides/Canteen to St.Marys/image.webp",
    "name": "Canteen to St. Marys"
  }
}
```

The app will automatically encode spaces to `%20`.

### Option B: Reorganize to Flat Structure (RECOMMENDED)

**Step 1:** Create a `panoramas` folder in your repo root

**Step 2:** Move and rename images:
```
cce-images/
└── panoramas/
    ├── canteen_to_st_marys.webp
    ├── main_gate_to_chavara.webp
    ├── st_marys_forest_route.webp
    ├── st_thomas_to_christ_hall.webp
    ├── techies_park.webp
    ├── hostel_junction.webp
    └── st_marys_main_road.webp
```

**Step 3:** In GeoJSON, use simple filenames:
```json
{
  "properties": {
    "panoUrl": "canteen_to_st_marys.webp",
    "name": "Canteen to St. Marys"
  }
}
```

**URLs become:**
```
https://thejas-krishna-p-r.github.io/cce-images/panoramas/canteen_to_st_marys.webp
```

---

## Recommended Image Naming

Use lowercase with underscores, no spaces:

| Current Folder | Recommended Filename |
|---------------|---------------------|
| Canteen to St.Marys | `canteen_to_st_marys.webp` |
| Main Gate to Chavara | `main_gate_to_chavara.webp` |
| St Mary_s through Forest route | `st_marys_forest_route.webp` |
| St thomas to Christ hall | `st_thomas_to_christ_hall.webp` |
| Techies Park | `techies_park.webp` |
| hostel jn nd parking lot mens hostel | `hostel_junction_parking.webp` |
| st marys front and main road... | `st_marys_main_road.webp` |

---

## Quick Test

After enabling GitHub Pages, test one of your image URLs:

```
https://thejas-krishna-p-r.github.io/cce-images/CCE%20MAP/Outsides/Canteen%20to%20St.Marys/YOUR_IMAGE_NAME.webp
```

Replace `YOUR_IMAGE_NAME.webp` with an actual image filename from that folder.

---

## My Recommendation

**Reorganize to flat structure:**

1. Create `panoramas` folder in repo root
2. Move all images there
3. Rename with descriptive lowercase names
4. Simpler URLs, easier to manage!

Would you like help reorganizing the structure?
