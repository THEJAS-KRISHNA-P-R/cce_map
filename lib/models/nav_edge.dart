/// Represents a weighted edge between two navigation nodes.
///
/// Edges have calculated weights based on distance and accessibility.
class NavEdge {
  /// Source node ID
  final String fromNodeId;

  /// Destination node ID
  final String toNodeId;

  /// Calculated weight (distance + penalties)
  final double weight;

  /// Whether this edge is wheelchair accessible
  final bool isAccessible;

  /// Type of connection
  final EdgeType type;

  /// Optional floor transition info
  final FloorTransition? floorTransition;

  const NavEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.weight,
    this.isAccessible = true,
    this.type = EdgeType.walkway,
    this.floorTransition,
  });

  /// Creates a copy with the given fields replaced
  NavEdge copyWith({
    String? fromNodeId,
    String? toNodeId,
    double? weight,
    bool? isAccessible,
    EdgeType? type,
    FloorTransition? floorTransition,
    bool clearFloorTransition = false,
  }) {
    return NavEdge(
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      weight: weight ?? this.weight,
      isAccessible: isAccessible ?? this.isAccessible,
      type: type ?? this.type,
      floorTransition: clearFloorTransition
          ? null
          : (floorTransition ?? this.floorTransition),
    );
  }

  /// Creates a NavEdge from JSON
  factory NavEdge.fromJson(Map<String, dynamic> json) {
    return NavEdge(
      fromNodeId: json['fromNodeId'] as String,
      toNodeId: json['toNodeId'] as String,
      weight: (json['weight'] as num).toDouble(),
      isAccessible: json['isAccessible'] as bool? ?? true,
      type: EdgeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EdgeType.walkway,
      ),
      floorTransition: json['floorTransition'] != null
          ? FloorTransition.fromJson(
              json['floorTransition'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts this edge to JSON
  Map<String, dynamic> toJson() {
    return {
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'weight': weight,
      'isAccessible': isAccessible,
      'type': type.name,
      'floorTransition': floorTransition?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavEdge &&
        other.fromNodeId == fromNodeId &&
        other.toNodeId == toNodeId;
  }

  @override
  int get hashCode => Object.hash(fromNodeId, toNodeId);

  @override
  String toString() {
    return 'NavEdge($fromNodeId -> $toNodeId, weight: $weight, type: $type)';
  }
}

/// Types of edges for different connection types
enum EdgeType {
  /// Standard walking path
  walkway,

  /// Staircase connection
  stairs,

  /// Elevator connection
  elevator,

  /// Ramp connection
  ramp,

  /// Indoor corridor
  corridor,

  /// Outdoor path
  outdoor,
}

/// Represents a floor transition for vertical edges
class FloorTransition {
  /// Starting floor
  final int fromFloor;

  /// Ending floor
  final int toFloor;

  const FloorTransition({required this.fromFloor, required this.toFloor});

  /// Number of floors traversed
  int get floorDifference => (toFloor - fromFloor).abs();

  factory FloorTransition.fromJson(Map<String, dynamic> json) {
    return FloorTransition(
      fromFloor: (json['fromFloor'] as num).toInt(),
      toFloor: (json['toFloor'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'fromFloor': fromFloor, 'toFloor': toFloor};
  }
}
