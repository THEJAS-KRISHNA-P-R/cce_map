import 'package:latlong2/latlong.dart';
import '../../models/models.dart';

/// Mock data for testing the navigation system.
///
/// This provides sample nodes and buildings to test the app
/// without requiring a real campus map.
class MockData {
  MockData._();

  /// Sample outdoor navigation nodes
  static List<NavNode> get sampleNodes => [
    // Main entrance area
    const NavNode(
      id: 'node_entrance_main',
      position: LatLng(12.9720, 77.5950),
      floor: 0,
      type: NodeType.entrance,
      edges: ['node_outdoor_01', 'node_outdoor_02'],
      accessible: true,
    ),

    // Outdoor walkway nodes
    const NavNode(
      id: 'node_outdoor_01',
      position: LatLng(12.9722, 77.5952),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_entrance_main', 'node_outdoor_03', 'node_bldg_a_entrance'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_outdoor_02',
      position: LatLng(12.9718, 77.5952),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_entrance_main', 'node_outdoor_04', 'node_bldg_b_entrance'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_outdoor_03',
      position: LatLng(12.9725, 77.5955),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_outdoor_01', 'node_outdoor_05'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_outdoor_04',
      position: LatLng(12.9715, 77.5955),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_outdoor_02', 'node_outdoor_06'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_outdoor_05',
      position: LatLng(12.9728, 77.5960),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_outdoor_03', 'node_outdoor_06'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_outdoor_06',
      position: LatLng(12.9712, 77.5960),
      floor: 0,
      type: NodeType.outdoor,
      edges: ['node_outdoor_04', 'node_outdoor_05'],
      accessible: true,
    ),

    // Building A entrance
    const NavNode(
      id: 'node_bldg_a_entrance',
      position: LatLng(12.9724, 77.5948),
      floor: 0,
      type: NodeType.entrance,
      buildingId: 'building_a',
      edges: ['node_outdoor_01', 'node_bldg_a_lobby'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_bldg_a_lobby',
      position: LatLng(12.9726, 77.5946),
      floor: 0,
      type: NodeType.indoor,
      buildingId: 'building_a',
      edges: ['node_bldg_a_entrance', 'node_bldg_a_stairs'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_bldg_a_stairs',
      position: LatLng(12.9728, 77.5946),
      floor: 0,
      type: NodeType.stairs,
      buildingId: 'building_a',
      edges: ['node_bldg_a_lobby', 'node_bldg_a_floor1'],
      accessible: false, // Stairs are not wheelchair accessible
    ),
    const NavNode(
      id: 'node_bldg_a_floor1',
      position: LatLng(12.9728, 77.5946),
      floor: 1,
      type: NodeType.indoor,
      buildingId: 'building_a',
      edges: ['node_bldg_a_stairs'],
      accessible: true,
    ),

    // Building B entrance
    const NavNode(
      id: 'node_bldg_b_entrance',
      position: LatLng(12.9716, 77.5948),
      floor: 0,
      type: NodeType.entrance,
      buildingId: 'building_b',
      edges: ['node_outdoor_02', 'node_bldg_b_lobby'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_bldg_b_lobby',
      position: LatLng(12.9714, 77.5946),
      floor: 0,
      type: NodeType.indoor,
      buildingId: 'building_b',
      edges: ['node_bldg_b_entrance', 'node_bldg_b_elevator'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_bldg_b_elevator',
      position: LatLng(12.9712, 77.5946),
      floor: 0,
      type: NodeType.elevator,
      buildingId: 'building_b',
      edges: ['node_bldg_b_lobby', 'node_bldg_b_floor1', 'node_bldg_b_floor2'],
      accessible: true, // Elevator is accessible
    ),
    const NavNode(
      id: 'node_bldg_b_floor1',
      position: LatLng(12.9712, 77.5946),
      floor: 1,
      type: NodeType.indoor,
      buildingId: 'building_b',
      edges: ['node_bldg_b_elevator'],
      accessible: true,
    ),
    const NavNode(
      id: 'node_bldg_b_floor2',
      position: LatLng(12.9712, 77.5946),
      floor: 2,
      type: NodeType.indoor,
      buildingId: 'building_b',
      edges: ['node_bldg_b_elevator'],
      accessible: true,
    ),
  ];

  /// Sample buildings
  static List<Building> get sampleBuildings => [
    Building(
      id: 'building_a',
      name: 'Building A - Academic Block',
      bounds: LatLngBounds(
        southwest: const LatLng(12.9722, 77.5942),
        northeast: const LatLng(12.9730, 77.5950),
      ),
      floors: [0, 1],
      code: 'BLK-A',
      description: 'Main academic building with classrooms and labs',
    ),
    Building(
      id: 'building_b',
      name: 'Building B - Administrative Block',
      bounds: LatLngBounds(
        southwest: const LatLng(12.9710, 77.5942),
        northeast: const LatLng(12.9718, 77.5950),
      ),
      floors: [0, 1, 2],
      code: 'BLK-B',
      description: 'Administrative offices and services',
    ),
  ];

  /// Loads mock data into the graph service
  static void loadMockData(dynamic graphService) {
    for (final node in sampleNodes) {
      graphService.addNode(node);
    }
    for (final building in sampleBuildings) {
      graphService.addBuilding(building);
    }
  }
}
