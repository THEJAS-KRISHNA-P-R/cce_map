import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cce_map/models/models.dart';
import 'package:cce_map/services/services.dart';

void main() {
  group('NavGraphService', () {
    late NavGraphService graphService;

    setUp(() {
      graphService = NavGraphService();
    });

    test('adds and retrieves node', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
      );

      graphService.addNode(node);

      expect(graphService.hasNode('test_node'), true);
      expect(graphService.getNode('test_node'), node);
      expect(graphService.nodes.length, 1);
    });

    test('updates node', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        floor: 0,
      );
      graphService.addNode(node);

      final updated = node.copyWith(floor: 5);
      graphService.updateNode(updated);

      expect(graphService.getNode('test_node')?.floor, 5);
    });

    test('removes node and cleans up edges', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_b'],
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
        edges: ['node_a'],
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);
      graphService.removeNode('node_a');

      expect(graphService.hasNode('node_a'), false);
      expect(graphService.getNode('node_b')?.edges.contains('node_a'), false);
    });

    test('connects nodes bidirectionally', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);
      graphService.connectNodes('node_a', 'node_b');

      expect(graphService.areConnected('node_a', 'node_b'), true);
      expect(graphService.areConnected('node_b', 'node_a'), true);
      expect(graphService.getNode('node_a')?.edges.contains('node_b'), true);
      expect(graphService.getNode('node_b')?.edges.contains('node_a'), true);
    });

    test('disconnects nodes bidirectionally', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_b'],
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
        edges: ['node_a'],
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);
      graphService.disconnectNodes('node_a', 'node_b');

      expect(graphService.areConnected('node_a', 'node_b'), false);
      expect(graphService.getNode('node_a')?.edges.contains('node_b'), false);
      expect(graphService.getNode('node_b')?.edges.contains('node_a'), false);
    });

    test('calculates edge weight with distance', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);

      final weight = graphService.calculateEdgeWeight('node_a', 'node_b');

      // Should be approximately 55-60 meters
      expect(weight, greaterThan(50));
      expect(weight, lessThan(70));
    });

    test('validates graph detects orphan edges', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_b', 'node_nonexistent'],
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
        edges: ['node_a'],
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);

      final issues = graphService.validateGraph();

      expect(issues.length, 1);
      expect(issues[0].contains('orphan'), true);
    });

    test('finds connected components', () {
      // Create two disconnected groups
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_b'],
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
        edges: ['node_a'],
      );
      final nodeC = NavNode(
        id: 'node_c',
        position: const LatLng(12.9730, 77.5960),
        edges: ['node_d'],
      );
      final nodeD = NavNode(
        id: 'node_d',
        position: const LatLng(12.9735, 77.5965),
        edges: ['node_c'],
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);
      graphService.addNode(nodeC);
      graphService.addNode(nodeD);

      final components = graphService.findConnectedComponents();

      expect(components.length, 2);
    });

    test('toJson and fromJson roundtrip', () {
      final nodeA = NavNode(
        id: 'node_a',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_b'],
      );
      final nodeB = NavNode(
        id: 'node_b',
        position: const LatLng(12.9720, 77.5950),
        edges: ['node_a'],
      );

      graphService.addNode(nodeA);
      graphService.addNode(nodeB);

      final json = graphService.toJson();

      final newService = NavGraphService();
      newService.fromJson(json);

      expect(newService.nodes.length, 2);
      expect(newService.hasNode('node_a'), true);
      expect(newService.hasNode('node_b'), true);
    });
  });
}
