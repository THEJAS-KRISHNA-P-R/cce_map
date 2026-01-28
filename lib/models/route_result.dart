import 'package:latlong2/latlong.dart';

/// Represents the result of a route calculation.
///
/// Contains the ordered list of nodes, polyline points for rendering,
/// and summary statistics.
class RouteResult {
  /// Ordered list of node IDs from start to destination
  final List<String> nodeIds;

  /// Polyline points for map rendering
  final List<LatLng> polylinePoints;

  /// Total distance in meters
  final double totalDistance;

  /// Whether the entire route is wheelchair accessible
  final bool isAccessible;

  /// Estimated walking time in seconds (assuming 1.4 m/s average)
  final int estimatedTimeSeconds;

  /// Number of floor transitions in the route
  final int floorTransitions;

  /// Starting floor number
  final int startFloor;

  /// Ending floor number
  final int endFloor;

  const RouteResult({
    required this.nodeIds,
    required this.polylinePoints,
    required this.totalDistance,
    this.isAccessible = true,
    this.estimatedTimeSeconds = 0,
    this.floorTransitions = 0,
    this.startFloor = 0,
    this.endFloor = 0,
  });

  /// Creates an empty result (no route found)
  factory RouteResult.empty() {
    return const RouteResult(
      nodeIds: [],
      polylinePoints: [],
      totalDistance: 0,
      isAccessible: true,
    );
  }

  /// Whether a valid route was found
  bool get isValid => nodeIds.length >= 2;

  /// Number of nodes in the route
  int get nodeCount => nodeIds.length;

  /// Formatted distance string
  String get distanceText {
    if (totalDistance < 1000) {
      return '${totalDistance.round()} m';
    }
    return '${(totalDistance / 1000).toStringAsFixed(1)} km';
  }

  /// Formatted time string
  String get timeText {
    if (estimatedTimeSeconds < 60) {
      return '$estimatedTimeSeconds sec';
    }
    final minutes = estimatedTimeSeconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours h $remainingMinutes min';
  }

  /// Creates a copy with the given fields replaced
  RouteResult copyWith({
    List<String>? nodeIds,
    List<LatLng>? polylinePoints,
    double? totalDistance,
    bool? isAccessible,
    int? estimatedTimeSeconds,
    int? floorTransitions,
    int? startFloor,
    int? endFloor,
  }) {
    return RouteResult(
      nodeIds: nodeIds ?? this.nodeIds,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      totalDistance: totalDistance ?? this.totalDistance,
      isAccessible: isAccessible ?? this.isAccessible,
      estimatedTimeSeconds: estimatedTimeSeconds ?? this.estimatedTimeSeconds,
      floorTransitions: floorTransitions ?? this.floorTransitions,
      startFloor: startFloor ?? this.startFloor,
      endFloor: endFloor ?? this.endFloor,
    );
  }

  @override
  String toString() {
    return 'RouteResult(nodes: ${nodeIds.length}, '
        'distance: $distanceText, time: $timeText)';
  }
}
