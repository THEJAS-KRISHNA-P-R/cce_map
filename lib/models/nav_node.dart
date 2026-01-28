import 'package:latlong2/latlong.dart';

/// Represents a navigation node in the campus map.
///
/// Each node is a physical point where someone can stand.
/// Nodes are connected by edges to form a navigation graph.
class NavNode {
  /// Unique identifier for this node
  final String id;

  /// MapTiler feature ID (original UUID from GeoJSON)
  final String? maptilerId;

  /// Geographic position of the node
  final LatLng position;

  /// Building ID this node belongs to (null for outdoor nodes)
  final String? buildingId;

  /// Floor number (0 = ground floor, negative for basement)
  final int floor;

  /// List of connected node IDs (edges)
  final List<String> edges;

  /// Whether this node is wheelchair accessible
  final bool accessible;

  /// Node type for visual differentiation
  final NodeType type;

  /// URL for panoramic image (if available)
  final String? panoUrl;

  /// Optional metadata for future extensions (3D nodes, QR codes, etc.)
  final Map<String, dynamic> metadata;

  const NavNode({
    required this.id,
    required this.position,
    this.maptilerId,
    this.buildingId,
    this.floor = 0,
    this.edges = const [],
    this.accessible = true,
    this.type = NodeType.outdoor,
    this.panoUrl,
    this.metadata = const {},
  });

  /// Creates a copy of this node with the given fields replaced
  NavNode copyWith({
    String? id,
    String? maptilerId,
    bool clearMaptilerId = false,
    LatLng? position,
    String? buildingId,
    bool clearBuildingId = false,
    int? floor,
    List<String>? edges,
    bool? accessible,
    NodeType? type,
    String? panoUrl,
    bool clearPanoUrl = false,
    Map<String, dynamic>? metadata,
  }) {
    return NavNode(
      id: id ?? this.id,
      maptilerId: clearMaptilerId ? null : (maptilerId ?? this.maptilerId),
      position: position ?? this.position,
      buildingId: clearBuildingId ? null : (buildingId ?? this.buildingId),
      floor: floor ?? this.floor,
      edges: edges ?? List.from(this.edges),
      accessible: accessible ?? this.accessible,
      type: type ?? this.type,
      panoUrl: clearPanoUrl ? null : (panoUrl ?? this.panoUrl),
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  /// Adds an edge to this node (returns new node)
  NavNode addEdge(String nodeId) {
    if (edges.contains(nodeId)) return this;
    return copyWith(edges: [...edges, nodeId]);
  }

  /// Removes an edge from this node (returns new node)
  NavNode removeEdge(String nodeId) {
    return copyWith(edges: edges.where((e) => e != nodeId).toList());
  }

  /// Creates a NavNode from JSON
  factory NavNode.fromJson(Map<String, dynamic> json) {
    return NavNode(
      id: json['id'] as String,
      maptilerId: json['maptilerId'] as String?,
      position: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      buildingId: json['buildingId'] as String?,
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      edges:
          (json['edges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      accessible: json['accessible'] as bool? ?? true,
      type: NodeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NodeType.outdoor,
      ),
      panoUrl: json['panoUrl'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Converts this node to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maptilerId': maptilerId,
      'lat': position.latitude,
      'lng': position.longitude,
      'buildingId': buildingId,
      'floor': floor,
      'edges': edges,
      'accessible': accessible,
      'type': type.name,
      'panoUrl': panoUrl,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NavNode(id: $id, position: $position, buildingId: $buildingId, '
        'floor: $floor, edges: $edges, accessible: $accessible, type: $type)';
  }
}

/// Types of navigation nodes for visual differentiation
enum NodeType {
  /// Outdoor walkway node (blue)
  outdoor,

  /// Indoor node within a building (green)
  indoor,

  /// Vertical connector - stairs (orange)
  stairs,

  /// Vertical connector - elevator (orange)
  elevator,

  /// Entry/exit point of a building
  entrance,

  /// Point of interest (room, service, etc.)
  poi,
}
