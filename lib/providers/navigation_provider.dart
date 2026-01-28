import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../services/services.dart';

/// Provider-based state management for navigation and panorama viewing.
///
/// Manages:
/// - isVisualMode: Toggle between 2D map and 3D panorama mode
/// - selectedNodeId: Currently selected/focused node
/// - Movement direction tracking for prefetching
/// - Prefetch queue for zero-latency panorama loading
class NavigationProvider extends ChangeNotifier {
  /// Whether we're in 3D visual/panorama mode
  bool _isVisualMode = false;

  /// Currently selected node ID
  String? _selectedNodeId;

  /// Previously selected node (for direction detection)
  String? _previousNodeId;

  /// Queue of node IDs to prefetch panoramas for
  List<String> _prefetchQueue = [];

  /// All nodes in the navigation graph
  List<NavNode> _nodes = [];

  /// Map of node ID to NavNode for quick lookup
  final Map<String, NavNode> _nodeMap = {};

  /// GeoJSON service for data loading
  final GeoJsonService _geoJsonService = GeoJsonService();

  // ============================================================
  // GETTERS
  // ============================================================

  /// Whether in 3D panorama mode
  bool get isVisualMode => _isVisualMode;

  /// Currently selected node ID
  String? get selectedNodeId => _selectedNodeId;

  /// Previously selected node ID
  String? get previousNodeId => _previousNodeId;

  /// Queue of node IDs for prefetching
  List<String> get prefetchQueue => List.unmodifiable(_prefetchQueue);

  /// All navigation nodes
  List<NavNode> get nodes => List.unmodifiable(_nodes);

  /// Gets a node by ID
  NavNode? getNode(String id) => _nodeMap[id];

  /// Gets the currently selected node
  NavNode? get selectedNode =>
      _selectedNodeId != null ? _nodeMap[_selectedNodeId] : null;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initializes the provider by loading GeoJSON data.
  Future<void> initialize(NavGraphService graphService) async {
    try {
      _nodes = await _geoJsonService.loadNavGraph();

      // Build lookup map
      _nodeMap.clear();
      for (final node in _nodes) {
        _nodeMap[node.id] = node;
        // Also add to graph service
        graphService.addNode(node);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize navigation: $e');
      rethrow;
    }
  }

  // ============================================================
  // MODE SWITCHING
  // ============================================================

  /// Toggles between 2D map and 3D panorama mode.
  void toggleVisualMode() {
    _isVisualMode = !_isVisualMode;
    notifyListeners();
  }

  /// Sets visual mode directly.
  void setVisualMode(bool value) {
    if (_isVisualMode != value) {
      _isVisualMode = value;
      notifyListeners();
    }
  }

  /// Enters 3D panorama mode for a specific node.
  void enterPanoramaMode(String nodeId) {
    selectNode(nodeId);
    _isVisualMode = true;
    notifyListeners();
  }

  /// Exits 3D panorama mode back to 2D map.
  void exitPanoramaMode() {
    _isVisualMode = false;
    notifyListeners();
  }

  // ============================================================
  // NODE SELECTION
  // ============================================================

  /// Selects a node and calculates prefetch queue.
  void selectNode(String nodeId) {
    if (!_nodeMap.containsKey(nodeId)) return;

    _previousNodeId = _selectedNodeId;
    _selectedNodeId = nodeId;
    _calculatePrefetchQueue();
    notifyListeners();
  }

  /// Clears the current selection.
  void clearSelection() {
    _previousNodeId = _selectedNodeId;
    _selectedNodeId = null;
    _prefetchQueue.clear();
    notifyListeners();
  }

  // ============================================================
  // PREFETCHING
  // ============================================================

  /// Calculates the next 3 nodes to prefetch based on movement direction.
  void _calculatePrefetchQueue() {
    _prefetchQueue.clear();

    if (_selectedNodeId == null) return;

    final currentNode = _nodeMap[_selectedNodeId];
    if (currentNode == null) return;

    // Get connected nodes
    final connectedNodes = <NavNode>[];
    for (final edgeId in currentNode.edges) {
      final node = _nodeMap[edgeId];
      if (node != null) {
        connectedNodes.add(node);
      }
    }

    if (connectedNodes.isEmpty) return;

    // If we have a previous node, prioritize nodes in the same direction
    if (_previousNodeId != null && _nodeMap.containsKey(_previousNodeId)) {
      final prevNode = _nodeMap[_previousNodeId]!;

      // Calculate movement direction (bearing)
      final movementBearing = _calculateBearing(
        prevNode.position,
        currentNode.position,
      );

      // Sort connected nodes by how close their direction is to our movement
      connectedNodes.sort((a, b) {
        final bearingA = _calculateBearing(currentNode.position, a.position);
        final bearingB = _calculateBearing(currentNode.position, b.position);

        final diffA = _bearingDifference(movementBearing, bearingA);
        final diffB = _bearingDifference(movementBearing, bearingB);

        return diffA.compareTo(diffB);
      });
    }

    // Take up to 3 nodes for prefetching
    for (int i = 0; i < connectedNodes.length && i < 3; i++) {
      _prefetchQueue.add(connectedNodes[i].id);
    }
  }

  /// Calculates bearing between two positions in degrees.
  double _calculateBearing(LatLng from, LatLng to) {
    final dLng = to.longitude - from.longitude;
    final y = dLng;
    final x = to.latitude - from.latitude;
    return (180 * (y.sign * x.abs()) / 3.14159) % 360;
  }

  /// Calculates the absolute difference between two bearings.
  double _bearingDifference(double bearing1, double bearing2) {
    var diff = (bearing1 - bearing2).abs();
    if (diff > 180) {
      diff = 360 - diff;
    }
    return diff;
  }

  // ============================================================
  // FIREBASE URL HELPERS
  // ============================================================

  /// Base URL for Firebase Storage (configure for your project).
  static const String _firebaseStorageBase =
      'https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/panoramas%2F';

  /// Gets the Firebase panorama URL for a node.
  String? getPanoramaUrl(String nodeId) {
    final node = _nodeMap[nodeId];
    if (node == null) return null;

    // Use custom pano_url if available, otherwise build default URL
    if (node.panoUrl != null && node.panoUrl!.isNotEmpty) {
      return node.panoUrl;
    }

    // Build URL from node ID (assumes .webp format)
    return '$_firebaseStorageBase$nodeId.webp?alt=media';
  }

  /// Gets panorama URLs for the prefetch queue.
  List<String> getPrefetchUrls() {
    return _prefetchQueue
        .map((id) => getPanoramaUrl(id))
        .whereType<String>()
        .toList();
  }
}
