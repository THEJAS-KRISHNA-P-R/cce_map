import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../core/constants/map_constants.dart';
import '../models/models.dart';

/// Service for loading and parsing GeoJSON data into navigation graph.
///
/// Loads from local assets first, falls back to MapTiler API on failure.
/// Parses Point features as nodes and LineString features as path connections.
class GeoJsonService {
  /// Local asset path for GeoJSON data
  static const String _localAssetPath = MapConstants.geojsonDataAsset;

  /// MapTiler API fallback URL
  static const String _fallbackUrl = MapConstants.maptilerGeoJsonUrl;

  /// Parsed nodes from GeoJSON
  final List<NavNode> _nodes = [];

  /// Map of position string to node ID for edge building
  final Map<String, String> _positionToNodeId = {};

  /// Gets all parsed nodes
  List<NavNode> get nodes => List.unmodifiable(_nodes);

  /// Loads and parses the navigation graph from GeoJSON.
  ///
  /// Tries local asset first, falls back to MapTiler API on error.
  /// Shows toast notification if local file is corrupt/missing.
  Future<List<NavNode>> loadNavGraph() async {
    try {
      return await _loadFromLocal();
    } catch (e) {
      // Show user-friendly toast for local file error
      Fluttertoast.showToast(
        msg: 'Local map data error. Loading from server...',
        toastLength: Toast.LENGTH_LONG,
      );

      try {
        return await _loadFromFallback();
      } catch (fallbackError) {
        Fluttertoast.showToast(
          msg: 'Failed to load map data. Please check your connection.',
          toastLength: Toast.LENGTH_LONG,
        );
        rethrow;
      }
    }
  }

  /// Loads GeoJSON from local assets
  Future<List<NavNode>> _loadFromLocal() async {
    final jsonString = await rootBundle.loadString(_localAssetPath);
    final geojson = json.decode(jsonString) as Map<String, dynamic>;
    return _parseGeoJson(geojson);
  }

  /// Loads GeoJSON from MapTiler API fallback
  Future<List<NavNode>> _loadFromFallback() async {
    final response = await http.get(Uri.parse(_fallbackUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load GeoJSON: ${response.statusCode}');
    }

    final geojson = json.decode(response.body) as Map<String, dynamic>;
    return _parseGeoJson(geojson);
  }

  /// Parses GeoJSON FeatureCollection into NavNodes.
  ///
  /// - Point features become navigation nodes
  /// - LineString features define edge connections between nodes
  List<NavNode> _parseGeoJson(Map<String, dynamic> geojson) {
    _nodes.clear();
    _positionToNodeId.clear();

    final features = geojson['features'] as List<dynamic>;

    // First pass: create nodes from Point features
    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final geometryType = geometry['type'] as String;

      if (geometryType == 'Point') {
        final node = _parsePointFeature(feature);
        _nodes.add(node);
        _positionToNodeId[_positionKey(node.position)] = node.id;
      }
    }

    // Second pass: create edges from LineString features
    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final geometryType = geometry['type'] as String;

      if (geometryType == 'LineString') {
        _parseLineStringFeature(feature);
      }
    }

    // Auto-connect nodes to ensure full connectivity
    // DISABLED: User wants full manual control over connections
    // Uncomment this if you want automatic edge generation between nearby nodes
    // _autoConnectNodes();

    return List.unmodifiable(_nodes);
  }

  /// Automatically connects nodes to their nearest neighbors.
  ///
  /// This ensures all nodes are reachable even if LineString features
  /// don't fully define the graph. Each node is connected to its K nearest
  /// neighbors within a maximum distance threshold.
  void _autoConnectNodes() {
    const int kNearestNeighbors = 3; // Connect to 3 nearest neighbors
    const double maxDistanceMeters = 100.0; // Max 100m connection distance

    for (int i = 0; i < _nodes.length; i++) {
      final node = _nodes[i];

      // Skip if node already has enough connections
      if (node.edges.length >= kNearestNeighbors) continue;

      // Find nearest neighbors
      final neighbors = <({String id, double distance})>[];

      for (int j = 0; j < _nodes.length; j++) {
        if (i == j) continue; // Skip self

        final otherNode = _nodes[j];
        final distance = _calculateDistance(node.position, otherNode.position);

        if (distance <= maxDistanceMeters) {
          neighbors.add((id: otherNode.id, distance: distance));
        }
      }

      // Sort by distance and take K nearest
      neighbors.sort((a, b) => a.distance.compareTo(b.distance));
      final toConnect = neighbors.take(kNearestNeighbors);

      // Connect to nearest neighbors
      for (final neighbor in toConnect) {
        _connectNodes(node.id, neighbor.id);
      }
    }
  }

  /// Calculates distance between two positions in meters.
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000; // meters

    final lat1 = pos1.latitude * pi / 180;
    final lat2 = pos2.latitude * pi / 180;
    final dLat = (pos2.latitude - pos1.latitude) * pi / 180;
    final dLng = (pos2.longitude - pos1.longitude) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  /// Parses a Point feature into a NavNode.
  NavNode _parsePointFeature(Map<String, dynamic> feature) {
    final id = feature['id'] as String;
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    // GeoJSON uses [longitude, latitude] order
    final lng = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    return NavNode(
      id: id,
      maptilerId: id,
      position: LatLng(lat, lng),
      panoUrl: properties['pano_url'] as String?,
      buildingId: properties['building_id'] as String?,
      floor: (properties['floor'] as num?)?.toInt() ?? 0,
      accessible: properties['accessible'] as bool? ?? true,
      type: _parseNodeType(properties['type'] as String?),
      metadata: Map<String, dynamic>.from(properties),
    );
  }

  /// Parses a LineString feature to create edges between existing nodes.
  void _parseLineStringFeature(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    // Connect consecutive points in the LineString
    for (int i = 0; i < coordinates.length - 1; i++) {
      final coord1 = coordinates[i] as List<dynamic>;
      final coord2 = coordinates[i + 1] as List<dynamic>;

      final pos1 = LatLng(
        (coord1[1] as num).toDouble(),
        (coord1[0] as num).toDouble(),
      );
      final pos2 = LatLng(
        (coord2[1] as num).toDouble(),
        (coord2[0] as num).toDouble(),
      );

      final nodeId1 = _findNodeByPosition(pos1);
      final nodeId2 = _findNodeByPosition(pos2);

      if (nodeId1 != null && nodeId2 != null && nodeId1 != nodeId2) {
        _connectNodes(nodeId1, nodeId2);
      }
    }
  }

  /// Finds a node ID by position (with tolerance for floating point).
  String? _findNodeByPosition(LatLng position) {
    // Direct lookup first
    final key = _positionKey(position);
    if (_positionToNodeId.containsKey(key)) {
      return _positionToNodeId[key];
    }

    // Fuzzy search with tolerance (0.00001 degrees ≈ 1 meter)
    const tolerance = 0.00001;
    for (final node in _nodes) {
      if ((node.position.latitude - position.latitude).abs() < tolerance &&
          (node.position.longitude - position.longitude).abs() < tolerance) {
        return node.id;
      }
    }

    return null;
  }

  /// Connects two nodes bidirectionally.
  void _connectNodes(String nodeId1, String nodeId2) {
    final node1Index = _nodes.indexWhere((n) => n.id == nodeId1);
    final node2Index = _nodes.indexWhere((n) => n.id == nodeId2);

    if (node1Index == -1 || node2Index == -1) return;

    final node1 = _nodes[node1Index];
    final node2 = _nodes[node2Index];

    // Add edges if not already connected
    if (!node1.edges.contains(nodeId2)) {
      _nodes[node1Index] = node1.addEdge(nodeId2);
    }
    if (!node2.edges.contains(nodeId1)) {
      _nodes[node2Index] = _nodes[node2Index].addEdge(nodeId1);
    }
  }

  /// Creates a position key for lookup.
  String _positionKey(LatLng position) {
    // Round to 8 decimal places for matching
    final lat = position.latitude.toStringAsFixed(8);
    final lng = position.longitude.toStringAsFixed(8);
    return '$lat,$lng';
  }

  /// Parses node type from string.
  NodeType _parseNodeType(String? typeStr) {
    if (typeStr == null) return NodeType.outdoor;

    switch (typeStr.toLowerCase()) {
      case 'indoor':
        return NodeType.indoor;
      case 'stairs':
        return NodeType.stairs;
      case 'elevator':
        return NodeType.elevator;
      case 'entrance':
        return NodeType.entrance;
      case 'poi':
        return NodeType.poi;
      default:
        return NodeType.outdoor;
    }
  }
}
