import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

/// Simple HTTP server to save GeoJSON data from the Flutter web app.
///
/// Run this server with: dart run lib/tools/save_server.dart
/// The Flutter app will send save requests to http://localhost:8080/save
void main() async {
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(_handleRequest);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Save server running on http://localhost:${server.port}');
  print('Waiting for save requests from Flutter app...');
}

Future<Response> _handleRequest(Request request) async {
  if (request.method == 'POST' && request.url.path == 'save') {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Path to the GeoJSON file
      final filePath = 'assets/data/cce_test.geojson';
      final file = File(filePath);

      // Write the GeoJSON data with pretty formatting
      final prettyJson = JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(prettyJson);

      print('✅ Saved changes to $filePath');
      print('   Features: ${(data['features'] as List).length}');

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Saved successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Error saving: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  return Response.notFound('Not found');
}
