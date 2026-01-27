import 'package:uuid/uuid.dart';

/// Utility class for generating unique IDs
class IdGenerator {
  static const _uuid = Uuid();

  IdGenerator._();

  /// Generates a unique node ID with prefix
  static String generateNodeId() {
    return 'node_${_uuid.v4().substring(0, 8)}';
  }

  /// Generates a unique building ID with prefix
  static String generateBuildingId() {
    return 'bldg_${_uuid.v4().substring(0, 8)}';
  }

  /// Generates a unique edge ID from two node IDs
  static String generateEdgeId(String fromNodeId, String toNodeId) {
    // Sort to ensure consistent ID regardless of direction
    final sorted = [fromNodeId, toNodeId]..sort();
    return 'edge_${sorted[0]}_${sorted[1]}';
  }

  /// Generates a generic unique ID
  static String generateId([String prefix = 'id']) {
    return '${prefix}_${_uuid.v4().substring(0, 8)}';
  }
}
