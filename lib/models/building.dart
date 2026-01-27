import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a building on the campus.
///
/// Buildings are logical containers for indoor nodes.
/// They define boundaries and available floors.
class Building {
  /// Unique identifier for this building
  final String id;

  /// Display name of the building
  final String name;

  /// Geographic bounds of the building footprint
  final LatLngBounds bounds;

  /// List of available floor numbers (0 = ground)
  final List<int> floors;

  /// Optional short code for the building (e.g., "BLK-A")
  final String? code;

  /// Optional description of the building
  final String? description;

  /// Floor overlay asset paths (future: SVG overlays per floor)
  final Map<int, String> floorOverlays;

  /// Additional metadata for future extensions
  final Map<String, dynamic> metadata;

  const Building({
    required this.id,
    required this.name,
    required this.bounds,
    this.floors = const [0],
    this.code,
    this.description,
    this.floorOverlays = const {},
    this.metadata = const {},
  });

  /// Creates a copy with the given fields replaced
  Building copyWith({
    String? id,
    String? name,
    LatLngBounds? bounds,
    List<int>? floors,
    String? code,
    bool clearCode = false,
    String? description,
    bool clearDescription = false,
    Map<int, String>? floorOverlays,
    Map<String, dynamic>? metadata,
  }) {
    return Building(
      id: id ?? this.id,
      name: name ?? this.name,
      bounds: bounds ?? this.bounds,
      floors: floors ?? List.from(this.floors),
      code: clearCode ? null : (code ?? this.code),
      description: clearDescription ? null : (description ?? this.description),
      floorOverlays: floorOverlays ?? Map.from(this.floorOverlays),
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  /// Check if a position is within this building's bounds
  bool containsPosition(LatLng position) {
    return bounds.contains(position);
  }

  /// Creates a Building from JSON
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      bounds: LatLngBounds(
        southwest: LatLng(
          (json['bounds']['sw']['lat'] as num).toDouble(),
          (json['bounds']['sw']['lng'] as num).toDouble(),
        ),
        northeast: LatLng(
          (json['bounds']['ne']['lat'] as num).toDouble(),
          (json['bounds']['ne']['lng'] as num).toDouble(),
        ),
      ),
      floors:
          (json['floors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [0],
      code: json['code'] as String?,
      description: json['description'] as String?,
      floorOverlays:
          (json['floorOverlays'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as String),
          ) ??
          {},
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Converts this building to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bounds': {
        'sw': {
          'lat': bounds.southwest.latitude,
          'lng': bounds.southwest.longitude,
        },
        'ne': {
          'lat': bounds.northeast.latitude,
          'lng': bounds.northeast.longitude,
        },
      },
      'floors': floors,
      'code': code,
      'description': description,
      'floorOverlays': floorOverlays.map((k, v) => MapEntry(k.toString(), v)),
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Building && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Building(id: $id, name: $name, floors: $floors)';
  }
}
