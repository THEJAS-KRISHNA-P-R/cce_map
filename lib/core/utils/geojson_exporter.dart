import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../services/nav_graph_service.dart';

/// Utility class for exporting navigation graph to GeoJSON format.
class GeoJsonExporter {
  /// Saves the navigation graph directly to the GeoJSON file via local server.
  static Future<bool> saveToFile(NavGraphService graphService) async {
    final geojson = exportToGeoJson(graphService);

    try {
      // Send to local save server
      final response = await html.HttpRequest.request(
        'http://localhost:8080/save',
        method: 'POST',
        sendData: jsonEncode(geojson),
        requestHeaders: {'Content-Type': 'application/json'},
      );

      if (response.status == 200) {
        print('✅ Changes saved to assets/data/cce_test.geojson');
        return true;
      } else {
        print('❌ Save failed: ${response.statusText}');
        return false;
      }
    } catch (e) {
      print('❌ Error saving: $e');
      print(
        '💡 Make sure the save server is running: dart run lib/tools/save_server.dart',
      );
      return false;
    }
  }

  /// Converts the navigation graph to GeoJSON format.
  static Map<String, dynamic> exportToGeoJson(NavGraphService graphService) {
    final features = <Map<String, dynamic>>[];

    // Export nodes as Point features
    for (final node in graphService.nodes) {
      features.add({
        'type': 'Feature',
        'id': node.id,
        'geometry': {
          'type': 'Point',
          'coordinates': [node.position.longitude, node.position.latitude],
        },
        'properties': {
          'type': node.type.name,
          'accessible': node.accessible,
          'floor': node.floor,
          if (node.buildingId != null) 'buildingId': node.buildingId,
          if (node.panoUrl != null) 'panoUrl': node.panoUrl,
          if (node.maptilerId != null) 'maptilerId': node.maptilerId,
          // Include metadata (contains node names)
          ...node.metadata,
        },
      });
    }

    // Export edges as LineString features
    final processedEdges = <String>{};
    for (final node in graphService.nodes) {
      for (final edgeId in node.edges) {
        // Create a unique edge identifier to avoid duplicates
        final edgeKey = node.id.compareTo(edgeId) < 0
            ? '${node.id}-$edgeId'
            : '$edgeId-${node.id}';

        if (!processedEdges.contains(edgeKey)) {
          processedEdges.add(edgeKey);

          final targetNode = graphService.getNode(edgeId);
          if (targetNode != null) {
            features.add({
              'type': 'Feature',
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [node.position.longitude, node.position.latitude],
                  [targetNode.position.longitude, targetNode.position.latitude],
                ],
              },
              'properties': {'from': node.id, 'to': edgeId},
            });
          }
        }
      }
    }

    return {'type': 'FeatureCollection', 'features': features};
  }
}
