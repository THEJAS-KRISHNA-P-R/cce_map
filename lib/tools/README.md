# Save Server for CCE Navigation App

This server allows the Flutter web app to save changes directly to the GeoJSON file.

## How to Use

1. **Start the Save Server**:
   ```bash
   dart run lib/tools/save_server.dart
   ```

2. **Run the Flutter App**:
   ```bash
   flutter run -d chrome
   ```

3. **Make Changes**:
   - Enable admin mode
   - Add/delete nodes, connect/disconnect paths, name nodes
   - Click the Save button (💾) OR the Download button (📥)

4. **Changes are Saved**:
   - The server automatically writes to `assets/data/cce_test.geojson`
   - Changes persist across app restarts
   - No manual file replacement needed!

## How It Works

- The Flutter app sends HTTP POST requests to `http://localhost:8080/save`
- The server receives the GeoJSON data
- The server writes it to `assets/data/cce_test.geojson`
- The file is automatically updated with your changes

## Troubleshooting

If you see "Save failed - is the server running?":
1. Make sure the save server is running in a separate terminal
2. Check that it's listening on port 8080
3. Restart the server if needed
