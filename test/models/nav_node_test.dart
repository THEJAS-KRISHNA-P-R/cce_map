import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:cce_map/models/nav_node.dart';

void main() {
  group('NavNode', () {
    test('creates node with required fields', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
      );

      expect(node.id, 'test_node');
      expect(node.position.latitude, 12.9716);
      expect(node.position.longitude, 77.5946);
      expect(node.buildingId, isNull);
      expect(node.floor, 0);
      expect(node.edges, isEmpty);
      expect(node.accessible, true);
      expect(node.type, NodeType.outdoor);
    });

    test('creates node with all fields', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        buildingId: 'building_a',
        floor: 2,
        edges: ['node_1', 'node_2'],
        accessible: false,
        type: NodeType.stairs,
        metadata: {'key': 'value'},
      );

      expect(node.buildingId, 'building_a');
      expect(node.floor, 2);
      expect(node.edges.length, 2);
      expect(node.accessible, false);
      expect(node.type, NodeType.stairs);
      expect(node.metadata['key'], 'value');
    });

    test('copyWith creates new node with updated fields', () {
      final original = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        floor: 0,
      );

      final updated = original.copyWith(floor: 5, accessible: false);

      expect(updated.id, 'test_node'); // unchanged
      expect(updated.floor, 5); // changed
      expect(updated.accessible, false); // changed
      expect(original.floor, 0); // original unchanged
    });

    test('addEdge adds new edge', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_1'],
      );

      final updated = node.addEdge('node_2');

      expect(updated.edges.length, 2);
      expect(updated.edges.contains('node_2'), true);
      expect(node.edges.length, 1); // original unchanged
    });

    test('addEdge does not duplicate existing edge', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_1'],
      );

      final updated = node.addEdge('node_1');

      expect(updated.edges.length, 1);
      expect(identical(updated, node), true); // same instance
    });

    test('removeEdge removes edge', () {
      final node = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        edges: ['node_1', 'node_2'],
      );

      final updated = node.removeEdge('node_1');

      expect(updated.edges.length, 1);
      expect(updated.edges.contains('node_1'), false);
      expect(updated.edges.contains('node_2'), true);
    });

    test('toJson and fromJson roundtrip', () {
      final original = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
        buildingId: 'building_a',
        floor: 2,
        edges: ['node_1', 'node_2'],
        accessible: false,
        type: NodeType.elevator,
        metadata: {'test': 123},
      );

      final json = original.toJson();
      final restored = NavNode.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.position.latitude, original.position.latitude);
      expect(restored.position.longitude, original.position.longitude);
      expect(restored.buildingId, original.buildingId);
      expect(restored.floor, original.floor);
      expect(restored.edges, original.edges);
      expect(restored.accessible, original.accessible);
      expect(restored.type, original.type);
    });

    test('equality based on id', () {
      final node1 = NavNode(
        id: 'test_node',
        position: const LatLng(12.9716, 77.5946),
      );

      final node2 = NavNode(
        id: 'test_node',
        position: const LatLng(0, 0), // different position
      );

      final node3 = NavNode(
        id: 'different_node',
        position: const LatLng(12.9716, 77.5946),
      );

      expect(node1 == node2, true); // same id
      expect(node1 == node3, false); // different id
      expect(node1.hashCode, node2.hashCode);
    });
  });
}
