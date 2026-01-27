import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map-related constants for the campus navigation system.
///
/// Configure campus bounds and default map settings here.
class MapConstants {
  MapConstants._();

  // ============================================================
  // CAMPUS BOUNDS - CONFIGURE THESE FOR YOUR CAMPUS MAP
  // ============================================================

  /// Southwest corner of the campus map overlay
  /// TODO: Replace with actual campus coordinates
  static const LatLng campusSouthwest = LatLng(10.354052, 76.212284);

  /// Northeast corner of the campus map overlay
  /// TODO: Replace with actual campus coordinates
  static const LatLng campusNortheast = LatLng(10.360867, 76.213160);

  /// Campus bounds for the ground overlay
  static final LatLngBounds campusBounds = LatLngBounds(
    southwest: campusSouthwest,
    northeast: campusNortheast,
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
