import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

import '../../models/models.dart';

/// Utilities for navigation calculations and formatting.
class NavigationUtils {
  NavigationUtils._();

  /// Calculates the bearing (direction) from one point to another in degrees.
  ///
  /// Returns a value between 0 and 360, where:
  /// - 0° = North
  /// - 90° = East
  /// - 180° = South
  /// - 270° = West
  static double calculateBearing(LatLng from, LatLng to) {
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);
    final dLng = _toRadians(to.longitude - from.longitude);

    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = math.atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Converts bearing in degrees to cardinal direction (N, NE, E, SE, S, SW, W, NW).
  static String getCardinalDirection(double bearing) {
    // Normalize bearing to 0-360
    final normalized = bearing % 360;

    if (normalized >= 337.5 || normalized < 22.5) return 'N';
    if (normalized >= 22.5 && normalized < 67.5) return 'NE';
    if (normalized >= 67.5 && normalized < 112.5) return 'E';
    if (normalized >= 112.5 && normalized < 157.5) return 'SE';
    if (normalized >= 157.5 && normalized < 202.5) return 'S';
    if (normalized >= 202.5 && normalized < 247.5) return 'SW';
    if (normalized >= 247.5 && normalized < 292.5) return 'W';
    if (normalized >= 292.5 && normalized < 337.5) return 'NW';

    return 'N'; // Fallback
  }

  /// Determines the type of turn based on the change in bearing.
  ///
  /// [prevBearing] is the bearing of the previous segment
  /// [nextBearing] is the bearing of the next segment
  static TurnType determineTurnType(double prevBearing, double nextBearing) {
    // Calculate the angle difference
    double diff = (nextBearing - prevBearing + 360) % 360;

    // Normalize to -180 to 180
    if (diff > 180) {
      diff -= 360;
    }

    final absDiff = diff.abs();

    // Classify the turn
    if (absDiff < 20) {
      return TurnType.straight;
    } else if (diff > 0) {
      // Right turn
      if (absDiff < 45) {
        return TurnType.slightRight;
      } else if (absDiff < 135) {
        return TurnType.right;
      } else if (absDiff < 160) {
        return TurnType.sharpRight;
      } else {
        return TurnType.uTurn;
      }
    } else {
      // Left turn
      if (absDiff < 45) {
        return TurnType.slightLeft;
      } else if (absDiff < 135) {
        return TurnType.left;
      } else if (absDiff < 160) {
        return TurnType.sharpLeft;
      } else {
        return TurnType.uTurn;
      }
    }
  }

  /// Formats distance in meters to a human-readable string.
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Generates a human-readable instruction for a navigation step.
  static String generateInstruction(NavigationStep step) {
    final distance = formatDistance(step.distance);
    final direction = step.direction.toLowerCase();

    switch (step.turnType) {
      case TurnType.start:
        return 'Start heading $direction';
      case TurnType.destination:
        return 'Arrive at destination';
      case TurnType.straight:
        return 'Continue straight for $distance';
      case TurnType.slightLeft:
        return 'Slight left and continue for $distance';
      case TurnType.left:
        return 'Turn left and walk $distance';
      case TurnType.sharpLeft:
        return 'Sharp left and walk $distance';
      case TurnType.slightRight:
        return 'Slight right and continue for $distance';
      case TurnType.right:
        return 'Turn right and walk $distance';
      case TurnType.sharpRight:
        return 'Sharp right and walk $distance';
      case TurnType.uTurn:
        return 'Make a U-turn and walk $distance';
    }
  }

  /// Converts degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Converts radians to degrees
  static double _toDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }
}
