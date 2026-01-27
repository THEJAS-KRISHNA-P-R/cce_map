import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // ============================================================
  // APP INFO
  // ============================================================

  static const String appName = 'CCE Indoor Navigation';
  static const String appVersion = '1.0.0';

  // ============================================================
  // NODE MARKER COLORS
  // ============================================================

  /// Outdoor node marker color
  static const Color outdoorNodeColor = Color(0xFF2196F3); // Blue

  /// Indoor node marker color
  static const Color indoorNodeColor = Color(0xFF4CAF50); // Green

  /// Vertical connector (stairs/elevator) marker color
  static const Color verticalNodeColor = Color(0xFFFF9800); // Orange

  /// Entrance node marker color
  static const Color entranceNodeColor = Color(0xFF9C27B0); // Purple

  /// POI node marker color
  static const Color poiNodeColor = Color(0xFFE91E63); // Pink

  /// Selected node marker color
  static const Color selectedNodeColor = Color(0xFFFFEB3B); // Yellow

  /// Start node marker color
  static const Color startNodeColor = Color(0xFF4CAF50); // Green

  /// End node marker color
  static const Color endNodeColor = Color(0xFFF44336); // Red

  // ============================================================
  // ROUTE POLYLINE STYLING
  // ============================================================

  /// Route polyline color
  static const Color routeColor = Color(0xFF2196F3); // Blue

  /// Route polyline width
  static const double routeWidth = 5.0;

  /// Edge preview polyline color (in editor)
  static const Color edgePreviewColor = Color(0xFF9E9E9E); // Gray

  /// Edge preview polyline width
  static const double edgePreviewWidth = 2.0;

  // ============================================================
  // NODE MARKER SIZING
  // ============================================================

  /// Default node marker radius
  static const double nodeMarkerRadius = 12.0;

  /// Selected node marker radius
  static const double selectedNodeMarkerRadius = 16.0;

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  /// Hive box name for nodes
  static const String nodesBoxName = 'nav_nodes';

  /// Hive box name for buildings
  static const String buildingsBoxName = 'buildings';

  /// Hive box name for app settings
  static const String settingsBoxName = 'settings';
}
