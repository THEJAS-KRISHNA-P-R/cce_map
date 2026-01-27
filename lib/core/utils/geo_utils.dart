import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geographic utility functions for distance and position calculations
class GeoUtils {
  GeoUtils._();

  /// Earth's radius in meters
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the Haversine distance between two LatLng points in meters
  static double calculateDistance(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLat = _toRadians(to.latitude - from.latitude);
    final dLng = _toRadians(to.longitude - from.longitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Calculates the center point of a list of LatLng points
  static LatLng calculateCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(totalLat / points.length, totalLng / points.length);
  }

  /// Checks if a point is within a given radius of another point
  static bool isWithinRadius(LatLng center, LatLng point, double radiusMeters) {
    return calculateDistance(center, point) <= radiusMeters;
  }

  /// Calculates bearing from one point to another in degrees
  static double calculateBearing(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLng = _toRadians(to.longitude - from.longitude);

    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = math.atan2(y, x);

    return (bearing * 180 / math.pi + 360) % 360;
  }

  /// Interpolates between two LatLng points
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * fraction,
      from.longitude + (to.longitude - from.longitude) * fraction,
    );
  }

  /// Creates a list of intermediate points between two LatLng points
  static List<LatLng> createIntermediatePoints(
    LatLng from,
    LatLng to,
    int count,
  ) {
    final points = <LatLng>[];
    for (int i = 1; i <= count; i++) {
      final fraction = i / (count + 1);
      points.add(interpolate(from, to, fraction));
    }
    return points;
  }

  /// Calculates estimated walking time in seconds
  static int estimateWalkingTime(
    double distanceMeters, {
    double speedMetersPerSecond = 1.4,
  }) {
    return (distanceMeters / speedMetersPerSecond).round();
  }

  /// Formats a distance value for display
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Formats a time value for display
  static String formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours h $remainingMinutes min';
  }
}
