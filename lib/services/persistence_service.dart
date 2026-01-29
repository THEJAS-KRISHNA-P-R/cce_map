import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import '../core/constants/map_constants.dart';
import 'nav_graph_service.dart';

/// Service for persisting navigation data using Firebase Firestore.
class PersistenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;

  /// Initializes the service
  Future<void> initialize() async {
    // Firestore is auto-initialized by Firebase.initializeApp() in main
    _initialized = true;
    print('PersistenceService (Firestore) initialized');
  }

  /// Ensures the service is initialized
  bool get isInitialized => _initialized;

  // ============================================================
  // NODE PERSISTENCE (FIRESTORE)
  // ============================================================

  /// Saves all nodes from the graph service to Firestore
  Future<void> saveNodes(NavGraphService graphService) async {
    final batch = _firestore.batch();

    for (final node in graphService.nodes) {
      final docRef = _firestore.collection('nodes').doc(node.id);
      batch.set(docRef, node.toJson());
    }

    try {
      await batch.commit();
      print('✅ Batch saved ${graphService.nodes.length} nodes to Firestore');
    } catch (e) {
      print('❌ Error batch saving nodes: $e');
      // If batch fails (too large), fallback to individual saves
      for (final node in graphService.nodes) {
        await saveNode(node);
      }
    }
  }

  /// Loads all nodes from Firestore
  Future<void> loadNodes(NavGraphService graphService) async {
    try {
      final snapshot = await _firestore.collection('nodes').get();

      if (snapshot.docs.isNotEmpty) {
        graphService.clearNodes();

        for (final doc in snapshot.docs) {
          try {
            final node = NavNode.fromJson(doc.data());
            graphService.addNode(node);
          } catch (e) {
            print('Error parsing node ${doc.id}: $e');
          }
        }
        print('✅ Loaded ${snapshot.docs.length} nodes from Firestore');
      } else {
        print('No nodes found in Firestore');
      }
    } catch (e) {
      print('❌ Error loading nodes from Firestore: $e');
    }
  }

  /// Saves a single node to Firestore
  Future<void> saveNode(NavNode node) async {
    try {
      await _firestore.collection('nodes').doc(node.id).set(node.toJson());
      // print('Saved node ${node.id} to Firestore');
    } catch (e) {
      print('❌ Error saving node ${node.id}: $e');
    }
  }

  /// Deletes a single node from Firestore
  Future<void> deleteNode(String nodeId) async {
    try {
      await _firestore.collection('nodes').doc(nodeId).delete();
      print('Deleted node $nodeId from Firestore');
    } catch (e) {
      print('❌ Error deleting node $nodeId: $e');
    }
  }

  // ============================================================
  // BUILDING PERSISTENCE
  // ============================================================

  /// Saves all buildings
  Future<void> saveBuildings(NavGraphService graphService) async {
    // TODO: Implement buildings collection in Firestore if needed
  }

  /// Loads all buildings
  Future<void> loadBuildings(NavGraphService graphService) async {
    // Load default buildings from assets for now
    await loadBuildingsFromAsset(graphService);
  }

  // ============================================================
  // FULL GRAPH PERSISTENCE
  // ============================================================

  /// Saves the entire graph
  Future<void> saveGraph(NavGraphService graphService) async {
    print('[PersistenceService] Saving graph to Firestore...');
    await saveNodes(graphService);
    // await saveBuildings(graphService);
    print('[PersistenceService] Graph saved successfully');
  }

  /// Loads the entire graph
  Future<void> loadGraph(NavGraphService graphService) async {
    await loadNodes(graphService);
    await loadBuildings(graphService);
  }

  /// Clears all data
  Future<void> clearAll() async {
    // Dangerous op in Firestore, avoided for now
    print('Clear all not implemented');
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

  /// Checks if connected
  bool hasLocalData() {
    return true;
  }

  int get localNodeCount => 0;
  int get localBuildingCount => 0;
}
