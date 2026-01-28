import 'dart:collection';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../core/utils/geo_utils.dart';
import '../core/constants/map_constants.dart';

/// Service for managing the navigation graph data structure.
///
/// Handles CRUD operations for nodes and edges, and provides
/// graph validation utilities.
class NavGraphService {
  /// All nodes in the graph, keyed by ID
  final Map<String, NavNode> _nodes = {};

  /// All buildings, keyed by ID
  final Map<String, Building> _buildings = {};

  // ============================================================
  // NODE OPERATIONS
  // ============================================================

  /// Gets all nodes as an unmodifiable list
  List<NavNode> get nodes => UnmodifiableListView(_nodes.values);

  /// Gets all node IDs
  Set<String> get nodeIds => _nodes.keys.toSet();

  /// Gets a node by ID
  NavNode? getNode(String id) => _nodes[id];

  /// Checks if a node exists
  bool hasNode(String id) => _nodes.containsKey(id);

  /// Adds a new node to the graph
  void addNode(NavNode node) {
    _nodes[node.id] = node;
  }

  /// Updates an existing node
  void updateNode(NavNode node) {
    if (!_nodes.containsKey(node.id)) {
      throw StateError('Node ${node.id} does not exist');
    }
    _nodes[node.id] = node;
  }

  /// Removes a node and all its edges
  void removeNode(String nodeId) {
    final node = _nodes[nodeId];
    if (node == null) return;

    // Remove edges from connected nodes
    for (final edgeId in node.edges) {
      final connectedNode = _nodes[edgeId];
      if (connectedNode != null) {
        _nodes[edgeId] = connectedNode.removeEdge(nodeId);
      }
    }

    // Remove the node itself
    _nodes.remove(nodeId);
  }

  /// Moves a node to a new position
  void moveNode(String nodeId, LatLng newPosition) {
    final node = _nodes[nodeId];
    if (node == null) return;
    _nodes[nodeId] = node.copyWith(position: newPosition);
  }

  /// Adds all nodes from a list
  void addAllNodes(List<NavNode> nodes) {
    for (final node in nodes) {
      _nodes[node.id] = node;
    }
  }

  /// Clears all nodes
  void clearNodes() {
    _nodes.clear();
  }

  // ============================================================
  // EDGE OPERATIONS
  // ============================================================

  /// Connects two nodes with a bidirectional edge
  void connectNodes(String nodeIdA, String nodeIdB) {
    final nodeA = _nodes[nodeIdA];
    final nodeB = _nodes[nodeIdB];

    if (nodeA == null || nodeB == null) {
      throw StateError('Both nodes must exist to create an edge');
    }

    // Add bidirectional edges
    _nodes[nodeIdA] = nodeA.addEdge(nodeIdB);
    _nodes[nodeIdB] = nodeB.addEdge(nodeIdA);
  }

  /// Disconnects two nodes
  void disconnectNodes(String nodeIdA, String nodeIdB) {
    final nodeA = _nodes[nodeIdA];
    final nodeB = _nodes[nodeIdB];

    if (nodeA != null) {
      _nodes[nodeIdA] = nodeA.removeEdge(nodeIdB);
    }
    if (nodeB != null) {
      _nodes[nodeIdB] = nodeB.removeEdge(nodeIdA);
    }
  }

  /// Checks if two nodes are connected
  bool areConnected(String nodeIdA, String nodeIdB) {
    final nodeA = _nodes[nodeIdA];
    return nodeA?.edges.contains(nodeIdB) ?? false;
  }

  /// Gets all edges as a list of (fromId, toId) pairs
  List<(String, String)> get edges {
    final edgeSet = <String>{};
    final result = <(String, String)>[];

    for (final node in _nodes.values) {
      for (final edgeId in node.edges) {
        // Create a unique key for this edge (sorted to avoid duplicates)
        final sorted = [node.id, edgeId]..sort();
        final key = '${sorted[0]}-${sorted[1]}';

        if (!edgeSet.contains(key)) {
          edgeSet.add(key);
          result.add((node.id, edgeId));
        }
      }
    }

    return result;
  }

  // ============================================================
  // BUILDING OPERATIONS
  // ============================================================

  /// Gets all buildings as an unmodifiable list
  List<Building> get buildings => UnmodifiableListView(_buildings.values);

  /// Gets a building by ID
  Building? getBuilding(String id) => _buildings[id];

  /// Adds a building
  void addBuilding(Building building) {
    _buildings[building.id] = building;
  }

  /// Updates a building
  void updateBuilding(Building building) {
    _buildings[building.id] = building;
  }

  /// Removes a building
  void removeBuilding(String buildingId) {
    _buildings.remove(buildingId);
  }

  /// Adds all buildings from a list
  void addAllBuildings(List<Building> buildings) {
    for (final building in buildings) {
      _buildings[building.id] = building;
    }
  }

  /// Clears all buildings
  void clearBuildings() {
    _buildings.clear();
  }

  /// Finds which building contains a given position
  Building? findBuildingAtPosition(LatLng position) {
    for (final building in _buildings.values) {
      if (building.containsPosition(position)) {
        return building;
      }
    }
    return null;
  }

  // ============================================================
  // EDGE WEIGHT CALCULATION
  // ============================================================

  /// Calculates the weight of an edge between two nodes
  double calculateEdgeWeight(
    String fromNodeId,
    String toNodeId, {
    bool requireAccessible = false,
  }) {
    final fromNode = _nodes[fromNodeId];
    final toNode = _nodes[toNodeId];

    if (fromNode == null || toNode == null) {
      return double.infinity;
    }

    // Base weight is the geographic distance
    double weight = GeoUtils.calculateDistance(
      fromNode.position,
      toNode.position,
    );

    // Add accessibility penalty if required and not accessible
    if (requireAccessible && (!fromNode.accessible || !toNode.accessible)) {
      weight *= MapConstants.accessibilityPenalty;
    }

    // Add stair penalty for vertical connectors
    if (fromNode.type == NodeType.stairs || toNode.type == NodeType.stairs) {
      weight *= MapConstants.stairsPenalty;
    }

    // Add floor transition penalty
    if (fromNode.floor != toNode.floor) {
      weight +=
          MapConstants.floorTransitionPenalty *
          (fromNode.floor - toNode.floor).abs();
    }

    return weight;
  }

  // ============================================================
  // GRAPH VALIDATION
  // ============================================================

  /// Validates the graph for orphan edges
  List<String> validateGraph() {
    final issues = <String>[];

    for (final node in _nodes.values) {
      for (final edgeId in node.edges) {
        if (!_nodes.containsKey(edgeId)) {
          issues.add('Node ${node.id} has orphan edge to $edgeId');
        }
      }
    }

    return issues;
  }

  /// Finds disconnected components in the graph
  List<Set<String>> findConnectedComponents() {
    final visited = <String>{};
    final components = <Set<String>>[];

    for (final nodeId in _nodes.keys) {
      if (!visited.contains(nodeId)) {
        final component = <String>{};
        _dfsComponent(nodeId, visited, component);
        components.add(component);
      }
    }

    return components;
  }

  void _dfsComponent(
    String nodeId,
    Set<String> visited,
    Set<String> component,
  ) {
    visited.add(nodeId);
    component.add(nodeId);

    final node = _nodes[nodeId];
    if (node == null) return;

    for (final edgeId in node.edges) {
      if (!visited.contains(edgeId)) {
        _dfsComponent(edgeId, visited, component);
      }
    }
  }

  // ============================================================
  // SERIALIZATION
  // ============================================================

  /// Exports the graph to JSON
  Map<String, dynamic> toJson() {
    return {
      'nodes': _nodes.values.map((n) => n.toJson()).toList(),
      'buildings': _buildings.values.map((b) => b.toJson()).toList(),
    };
  }

  /// Imports the graph from JSON
  void fromJson(Map<String, dynamic> json) {
    clearNodes();
    clearBuildings();

    final nodesList = json['nodes'] as List<dynamic>?;
    if (nodesList != null) {
      for (final nodeJson in nodesList) {
        final node = NavNode.fromJson(nodeJson as Map<String, dynamic>);
        _nodes[node.id] = node;
      }
    }

    final buildingsList = json['buildings'] as List<dynamic>?;
    if (buildingsList != null) {
      for (final buildingJson in buildingsList) {
        final building = Building.fromJson(
          buildingJson as Map<String, dynamic>,
        );
        _buildings[building.id] = building;
      }
    }
  }

  // ============================================================
  // QUERY HELPERS
  // ============================================================

  /// Gets nodes by building ID
  List<NavNode> getNodesByBuilding(String? buildingId) {
    return _nodes.values.where((n) => n.buildingId == buildingId).toList();
  }

  /// Gets nodes by floor
  List<NavNode> getNodesByFloor(int floor) {
    return _nodes.values.where((n) => n.floor == floor).toList();
  }

  /// Gets nodes by type
  List<NavNode> getNodesByType(NodeType type) {
    return _nodes.values.where((n) => n.type == type).toList();
  }

  /// Finds the nearest node to a given position
  NavNode? findNearestNode(LatLng position, {double maxDistanceMeters = 50}) {
    NavNode? nearest;
    double minDistance = double.infinity;

    for (final node in _nodes.values) {
      final distance = GeoUtils.calculateDistance(position, node.position);
      if (distance < minDistance && distance <= maxDistanceMeters) {
        minDistance = distance;
        nearest = node;
      }
    }

    return nearest;
  }
}
