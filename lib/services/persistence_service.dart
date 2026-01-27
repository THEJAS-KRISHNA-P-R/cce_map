import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/map_constants.dart';
import 'nav_graph_service.dart';

/// Service for persisting navigation data locally.
///
/// Supports offline-first operation with Hive for fast local storage
/// and JSON export/import for data portability.
class PersistenceService {
  Box<String>? _nodesBox;
  Box<String>? _buildingsBox;
  bool _initialized = false;

  /// Initializes Hive and opens required boxes
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      _nodesBox = await Hive.openBox<String>(AppConstants.nodesBoxName);
      _buildingsBox = await Hive.openBox<String>(AppConstants.buildingsBoxName);

      _initialized = true;
    } catch (e) {
      print('Hive initialization failed: $e');
      // Continue without Hive on web if it fails
      _initialized = true;
    }
  }

  /// Ensures the service is initialized
  bool get isInitialized => _initialized;

  // ============================================================
  // NODE PERSISTENCE
  // ============================================================

  /// Saves all nodes from the graph service
  Future<void> saveNodes(NavGraphService graphService) async {
    if (_nodesBox == null) return;

    await _nodesBox!.clear();

    for (final node in graphService.nodes) {
      await _nodesBox!.put(node.id, jsonEncode(node.toJson()));
    }
  }

  /// Loads all nodes into the graph service
  Future<void> loadNodes(NavGraphService graphService) async {
    if (_nodesBox == null) return;

    graphService.clearNodes();

    for (final key in _nodesBox!.keys) {
      final jsonStr = _nodesBox!.get(key);
      if (jsonStr != null) {
        final node = NavNode.fromJson(jsonDecode(jsonStr));
        graphService.addNode(node);
      }
    }
  }

  /// Saves a single node
  Future<void> saveNode(NavNode node) async {
    if (_nodesBox == null) return;
    await _nodesBox!.put(node.id, jsonEncode(node.toJson()));
  }

  /// Deletes a single node
  Future<void> deleteNode(String nodeId) async {
    if (_nodesBox == null) return;
    await _nodesBox!.delete(nodeId);
  }

  // ============================================================
  // BUILDING PERSISTENCE
  // ============================================================

  /// Saves all buildings from the graph service
  Future<void> saveBuildings(NavGraphService graphService) async {
    if (_buildingsBox == null) return;

    await _buildingsBox!.clear();

    for (final building in graphService.buildings) {
      await _buildingsBox!.put(building.id, jsonEncode(building.toJson()));
    }
  }

  /// Loads all buildings into the graph service
  Future<void> loadBuildings(NavGraphService graphService) async {
    if (_buildingsBox == null) return;

    graphService.clearBuildings();

    for (final key in _buildingsBox!.keys) {
      final jsonStr = _buildingsBox!.get(key);
      if (jsonStr != null) {
        final building = Building.fromJson(jsonDecode(jsonStr));
        graphService.addBuilding(building);
      }
    }
  }

  // ============================================================
  // FULL GRAPH PERSISTENCE
  // ============================================================

  /// Saves the entire graph
  Future<void> saveGraph(NavGraphService graphService) async {
    await saveNodes(graphService);
    await saveBuildings(graphService);
  }

  /// Loads the entire graph
  Future<void> loadGraph(NavGraphService graphService) async {
    await loadNodes(graphService);
    await loadBuildings(graphService);
  }

  /// Clears all persisted data
  Future<void> clearAll() async {
    if (_nodesBox != null) await _nodesBox!.clear();
    if (_buildingsBox != null) await _buildingsBox!.clear();
  }

  // ============================================================
  // JSON EXPORT/IMPORT
  // ============================================================

  /// Exports the graph to a JSON string
  String exportToJson(NavGraphService graphService) {
    return jsonEncode(graphService.toJson());
  }

  /// Imports the graph from a JSON string
  void importFromJson(NavGraphService graphService, String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    graphService.fromJson(data);
  }

  // ============================================================
  // ASSET LOADING
  // ============================================================

  /// Loads nodes from the bundled asset file
  Future<void> loadNodesFromAsset(NavGraphService graphService) async {
    try {
      final jsonStr = await rootBundle.loadString(MapConstants.nodesDataAsset);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final nodesList = data['nodes'] as List<dynamic>?;
      if (nodesList != null) {
        for (final nodeJson in nodesList) {
          final node = NavNode.fromJson(nodeJson as Map<String, dynamic>);
          graphService.addNode(node);
        }
      }
    } catch (e) {
      // Asset may not exist yet, that's okay
      print('Could not load nodes from asset: $e');
    }
  }

  /// Loads buildings from the bundled asset file
  Future<void> loadBuildingsFromAsset(NavGraphService graphService) async {
    try {
      final jsonStr = await rootBundle.loadString(
        MapConstants.buildingsDataAsset,
      );
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final buildingsList = data['buildings'] as List<dynamic>?;
      if (buildingsList != null) {
        for (final buildingJson in buildingsList) {
          final building = Building.fromJson(
            buildingJson as Map<String, dynamic>,
          );
          graphService.addBuilding(building);
        }
      }
    } catch (e) {
      // Asset may not exist yet, that's okay
      print('Could not load buildings from asset: $e');
    }
  }

  /// Loads the complete graph from assets (initial data)
  Future<void> loadFromAssets(NavGraphService graphService) async {
    await loadNodesFromAsset(graphService);
    await loadBuildingsFromAsset(graphService);
  }

  // ============================================================
  // SYNC STATUS
  // ============================================================

  /// Checks if local data exists
  bool hasLocalData() {
    if (_nodesBox == null || _buildingsBox == null) return false;
    return _nodesBox!.isNotEmpty || _buildingsBox!.isNotEmpty;
  }

  /// Gets the count of locally stored nodes
  int get localNodeCount {
    return _nodesBox?.length ?? 0;
  }

  /// Gets the count of locally stored buildings
  int get localBuildingCount {
    return _buildingsBox?.length ?? 0;
  }
}
