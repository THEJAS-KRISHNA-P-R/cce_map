// Simple widget test that doesn't require Google Maps initialization
// Full widget tests would require mocking the Google Maps plugin

import 'package:flutter_test/flutter_test.dart';
import 'package:cce_map/models/models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Model Unit Tests', () {
    test('NavNode creates correctly', () {
      const node = NavNode(id: 'test', position: LatLng(12.9716, 77.5946));
      expect(node.id, 'test');
    });

    test('RouteResult.empty() creates invalid route', () {
      final route = RouteResult.empty();
      expect(route.isValid, false);
    });
  });
}
