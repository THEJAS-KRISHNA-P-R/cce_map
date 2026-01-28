import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Map-related constants for the campus navigation system.
///
/// Configure campus bounds and default map settings here.
class MapConstants {
  MapConstants._();

  // ============================================================
  // MAPTILER CONFIGURATION
  // ============================================================

  /// MapTiler API key for tile server access
  static const String maptilerApiKey = 'AMnMKBwdNa7Bxnr285dU';

  /// MapTiler streets-v2 tile URL template
  static const String maptilerTileUrl =
      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$maptilerApiKey';

  /// MapTiler GeoJSON fallback URL
  static const String maptilerGeoJsonUrl =
      'https://api.maptiler.com/data/019c058f-eab4-722d-b3c6-707755573081/features.json?key=$maptilerApiKey';

  // ============================================================
  // CAMPUS BOUNDS - CONFIGURE THESE FOR YOUR CAMPUS MAP
  // ============================================================

  /// Southwest corner of the campus map overlay
  static const LatLng campusSouthwest = LatLng(10.354052, 76.212284);

  /// Northeast corner of the campus map overlay
  static const LatLng campusNortheast = LatLng(10.360867, 76.213160);

  /// Campus bounds for the ground overlay
  static final LatLngBounds campusBounds = LatLngBounds(
    campusSouthwest,
    campusNortheast,
  );

  /// Center of the campus
  static LatLng get campusCenter => LatLng(
    (campusSouthwest.latitude + campusNortheast.latitude) / 2,
    (campusSouthwest.longitude + campusNortheast.longitude) / 2,
  );

  // ============================================================
  // DEFAULT MAP SETTINGS
  // ============================================================

  /// Default zoom level when viewing the campus
  static const double defaultZoom = 17.0;

  /// Minimum zoom level (zoomed out)
  static const double minZoom = 14.0;

  /// Maximum zoom level (zoomed in)
  static const double maxZoom = 21.0;

  /// Ground overlay transparency (0.0 = opaque, 1.0 = transparent)
  static const double overlayTransparency = 0.0;

  // ============================================================
  // ASSET PATHS
  // ============================================================

  /// Path to the campus map overlay image
  static const String campusMapAsset = 'assets/maps/campus.png';

  /// Path to the GeoJSON data file
  static const String geojsonDataAsset = 'assets/data/cce_test.geojson';

  /// Path to the nodes data file
  static const String nodesDataAsset = 'assets/data/nodes.json';

  /// Path to the buildings data file
  static const String buildingsDataAsset = 'assets/data/buildings.json';

  // ============================================================
  // ROUTING WEIGHTS
  // ============================================================

  /// Penalty multiplier for stairs (non-accessible routes)
  static const double stairsPenalty = 1.5;

  /// Penalty multiplier for non-accessible paths
  static const double accessibilityPenalty = 2.0;

  /// Penalty per floor transition
  static const double floorTransitionPenalty = 10.0;

  /// Average walking speed in meters per second
  static const double averageWalkingSpeed = 1.4;
}
