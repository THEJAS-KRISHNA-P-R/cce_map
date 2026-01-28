import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:cce_map/models/models.dart';
import 'package:cce_map/services/services.dart';

void main() {
  group('RoutingService', () {
    late NavGraphService graphService;
    late RoutingService routingService;

    setUp(() {
      graphService = NavGraphService();
      routingService = RoutingService(graphService);

      // Create a simple test graph:
      // A --- B --- C
      //       |
      //       D --- E

      graphService.addNode(
        const NavNode(
          id: 'A',
          position: LatLng(12.9700, 77.5900),
          edges: ['B'],
        ),
      );
      graphService.addNode(
        const NavNode(
          id: 'B',
          position: LatLng(12.9705, 77.5905),
          edges: ['A', 'C', 'D'],
        ),
      );
      graphService.addNode(
        const NavNode(
          id: 'C',
          position: LatLng(12.9710, 77.5910),
          edges: ['B'],
        ),
      );
      graphService.addNode(
        const NavNode(
          id: 'D',
          position: LatLng(12.9705, 77.5895),
          edges: ['B', 'E'],
        ),
      );
      graphService.addNode(
        const NavNode(
          id: 'E',
          position: LatLng(12.9700, 77.5890),
          edges: ['D'],
        ),
      );
    });

    test('finds route between adjacent nodes', () {
      final route = routingService.findRoute('A', 'B');

      expect(route.isValid, true);
      expect(route.nodeIds, ['A', 'B']);
      expect(route.totalDistance, greaterThan(0));
    });

    test('finds shortest path through multiple nodes', () {
      final route = routingService.findRoute('A', 'C');

      expect(route.isValid, true);
      expect(route.nodeIds, ['A', 'B', 'C']);
    });

    test('finds route to a distant node', () {
      final route = routingService.findRoute('A', 'E');

      expect(route.isValid, true);
      expect(route.nodeIds, ['A', 'B', 'D', 'E']);
    });

    test('returns empty route for same start/end', () {
      final route = routingService.findRoute('A', 'A');

      expect(route.nodeIds.length, 1);
      expect(route.nodeIds[0], 'A');
    });

    test('returns empty route for non-existent nodes', () {
      final route = routingService.findRoute('A', 'X');

      expect(route.isValid, false);
      expect(route.nodeIds, isEmpty);
    });

    test('returns empty route for disconnected nodes', () {
      // Add a disconnected node
      graphService.addNode(
        const NavNode(
          id: 'Z',
          position: LatLng(12.9800, 77.6000),
          edges: [], // No connections
        ),
      );

      final route = routingService.findRoute('A', 'Z');

      expect(route.isValid, false);
    });

    test('respects accessibility constraint', () {
      // Create graph with accessible and non-accessible paths
      final accessibleGraph = NavGraphService();

      accessibleGraph.addNode(
        const NavNode(
          id: 'start',
          position: LatLng(12.9700, 77.5900),
          edges: ['stairs', 'elevator'],
          accessible: true,
        ),
      );
      accessibleGraph.addNode(
        const NavNode(
          id: 'stairs',
          position: LatLng(12.9702, 77.5902),
          edges: ['start', 'end'],
          accessible: false, // Stairs are not accessible
          type: NodeType.stairs,
        ),
      );
      accessibleGraph.addNode(
        const NavNode(
          id: 'elevator',
          position: LatLng(12.9705, 77.5905), // Longer path
          edges: ['start', 'end_via_elevator'],
          accessible: true,
          type: NodeType.elevator,
        ),
      );
      accessibleGraph.addNode(
        const NavNode(
          id: 'end',
          position: LatLng(12.9704, 77.5904),
          edges: ['stairs'],
          accessible: true,
        ),
      );
      accessibleGraph.addNode(
        const NavNode(
          id: 'end_via_elevator',
          position: LatLng(12.9706, 77.5906),
          edges: ['elevator'],
          accessible: true,
        ),
      );

      final accessibleRouting = RoutingService(accessibleGraph);

      // Without accessibility requirement, might use stairs
      final anyRoute = accessibleRouting.findRoute('start', 'end');
      expect(anyRoute.isValid, true);

      // With accessibility requirement, should avoid stairs
      final accessibleRoute = accessibleRouting.findRoute(
        'start',
        'end',
        requireAccessible: true,
      );

      // Route to 'end' requires stairs which is not accessible
      // So this should return empty
      expect(accessibleRoute.isValid, false);
    });

    test('calculates correct distance', () {
      final route = routingService.findRoute('A', 'B');

      // Approximate distance between the two close points
      expect(route.totalDistance, greaterThan(50));
      expect(route.totalDistance, lessThan(100));
    });

    test('calculates estimated time', () {
      final route = routingService.findRoute('A', 'C');

      // Should have an estimated time > 0
      expect(route.estimatedTimeSeconds, greaterThan(0));
    });

    test('finds reachable nodes', () {
      final reachable = routingService.findReachableNodes('A');

      expect(reachable.length, 5);
      expect(reachable.contains('A'), true);
      expect(reachable.contains('B'), true);
      expect(reachable.contains('C'), true);
      expect(reachable.contains('D'), true);
      expect(reachable.contains('E'), true);
    });
  });
}
