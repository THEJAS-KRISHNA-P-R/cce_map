/// Represents a single step in turn-by-turn navigation.
///
/// Each step covers the segment from one node to the next,
/// with distance, direction, and instruction information.
class NavigationStep {
  /// ID of the node this step starts from
  final String fromNodeId;

  /// ID of the node this step goes to
  final String toNodeId;

  /// Distance in meters for this step
  final double distance;

  /// Cardinal direction (N, NE, E, SE, S, SW, W, NW)
  final String direction;

  /// Numeric bearing in degrees (0-360, where 0 is North)
  final double bearing;

  /// Human-readable instruction (e.g., "Walk 20m north")
  final String instruction;

  /// Type of turn required for this step
  final TurnType turnType;

  const NavigationStep({
    required this.fromNodeId,
    required this.toNodeId,
    required this.distance,
    required this.direction,
    required this.bearing,
    required this.instruction,
    required this.turnType,
  });

  /// Creates a copy with the given fields replaced
  NavigationStep copyWith({
    String? fromNodeId,
    String? toNodeId,
    double? distance,
    String? direction,
    double? bearing,
    String? instruction,
    TurnType? turnType,
  }) {
    return NavigationStep(
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      distance: distance ?? this.distance,
      direction: direction ?? this.direction,
      bearing: bearing ?? this.bearing,
      instruction: instruction ?? this.instruction,
      turnType: turnType ?? this.turnType,
    );
  }

  /// Formatted distance string
  String get distanceText {
    if (distance < 1000) {
      return '${distance.round()} m';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  String toString() {
    return 'NavigationStep(from: $fromNodeId, to: $toNodeId, '
        'distance: $distanceText, direction: $direction, turn: ${turnType.name})';
  }
}

/// Types of turns for navigation instructions
enum TurnType {
  /// Continue straight ahead
  straight,

  /// Slight turn to the left
  slightLeft,

  /// Turn left
  left,

  /// Sharp turn to the left
  sharpLeft,

  /// Slight turn to the right
  slightRight,

  /// Turn right
  right,

  /// Sharp turn to the right
  sharpRight,

  /// U-turn
  uTurn,

  /// Starting point
  start,

  /// Destination reached
  destination,
}

/// Extension to get user-friendly turn descriptions
extension TurnTypeExtension on TurnType {
  /// Get a human-readable description of the turn
  String get description {
    switch (this) {
      case TurnType.straight:
        return 'Continue straight';
      case TurnType.slightLeft:
        return 'Slight left';
      case TurnType.left:
        return 'Turn left';
      case TurnType.sharpLeft:
        return 'Sharp left';
      case TurnType.slightRight:
        return 'Slight right';
      case TurnType.right:
        return 'Turn right';
      case TurnType.sharpRight:
        return 'Sharp right';
      case TurnType.uTurn:
        return 'Make a U-turn';
      case TurnType.start:
        return 'Start';
      case TurnType.destination:
        return 'Arrive at destination';
    }
  }

  /// Get an icon name for the turn type
  String get iconName {
    switch (this) {
      case TurnType.straight:
        return 'arrow_upward';
      case TurnType.slightLeft:
        return 'arrow_back';
      case TurnType.left:
        return 'arrow_back';
      case TurnType.sharpLeft:
        return 'arrow_back';
      case TurnType.slightRight:
        return 'arrow_forward';
      case TurnType.right:
        return 'arrow_forward';
      case TurnType.sharpRight:
        return 'arrow_forward';
      case TurnType.uTurn:
        return 'u_turn_left';
      case TurnType.start:
        return 'place';
      case TurnType.destination:
        return 'flag';
    }
  }
}
