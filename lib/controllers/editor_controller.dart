import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../core/utils/id_generator.dart';

/// Editor tool modes
enum EditorTool {
  /// View mode - no editing
  view,

  /// Add node mode
  addNode,

  /// Move node mode
  moveNode,

  /// Delete node mode
  deleteNode,

  /// Connect nodes mode
  connectNodes,
}

/// State for the editor controller
class EditorState {
  /// Whether admin mode is enabled
  final bool isAdminMode;

  /// Current editor tool
  final EditorTool currentTool;

  /// Currently selected node (for move/delete/connect)
  final String? selectedNodeId;

  /// First node for connection (in connect mode)
  final String? connectFromNodeId;

  /// Whether there are unsaved changes
  final bool hasUnsavedChanges;

  /// Current node type to create
  final NodeType nodeTypeToCreate;

  /// Whether the node is accessible
  final bool createAccessible;

  /// Current floor for new nodes
  final int currentFloor;

  const EditorState({
    this.isAdminMode = false,
    this.currentTool = EditorTool.view,
    this.selectedNodeId,
    this.connectFromNodeId,
    this.hasUnsavedChanges = false,
    this.nodeTypeToCreate = NodeType.outdoor,
    this.createAccessible = true,
    this.currentFloor = 0,
  });

  EditorState copyWith({
    bool? isAdminMode,
    EditorTool? currentTool,
    String? selectedNodeId,
    bool clearSelectedNodeId = false,
    String? connectFromNodeId,
    bool clearConnectFromNodeId = false,
    bool? hasUnsavedChanges,
    NodeType? nodeTypeToCreate,
    bool? createAccessible,
    int? currentFloor,
  }) {
    return EditorState(
      isAdminMode: isAdminMode ?? this.isAdminMode,
      currentTool: currentTool ?? this.currentTool,
      selectedNodeId: clearSelectedNodeId
          ? null
          : (selectedNodeId ?? this.selectedNodeId),
      connectFromNodeId: clearConnectFromNodeId
          ? null
          : (connectFromNodeId ?? this.connectFromNodeId),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      nodeTypeToCreate: nodeTypeToCreate ?? this.nodeTypeToCreate,
      createAccessible: createAccessible ?? this.createAccessible,
      currentFloor: currentFloor ?? this.currentFloor,
    );
  }
}

/// Controller for admin map editing operations.
///
/// This controller handles:
/// - Admin mode toggle
/// - Node creation, movement, deletion
/// - Edge connection
///
/// It operates on the NavGraphService and marks changes as unsaved.
class EditorController extends StateNotifier<EditorState> {
  final NavGraphService _graphService;
  final PersistenceService _persistenceService;

  EditorController(this._graphService, this._persistenceService)
    : super(const EditorState());

  // ============================================================
  // MODE MANAGEMENT
  // ============================================================

  /// Toggles admin mode
  void toggleAdminMode() {
    state = state.copyWith(
      isAdminMode: !state.isAdminMode,
      currentTool: state.isAdminMode ? EditorTool.view : EditorTool.addNode,
      clearSelectedNodeId: true,
      clearConnectFromNodeId: true,
    );
  }

  /// Sets the current editor tool
  void setTool(EditorTool tool) {
    state = state.copyWith(
      currentTool: tool,
      clearSelectedNodeId: true,
      clearConnectFromNodeId: true,
    );
  }

  /// Sets the node type to create
  void setNodeType(NodeType type) {
    state = state.copyWith(nodeTypeToCreate: type);
  }

  /// Sets the accessibility flag for new nodes
  void setAccessible(bool accessible) {
    state = state.copyWith(createAccessible: accessible);
  }

  /// Sets the current floor for new nodes
  void setCurrentFloor(int floor) {
    state = state.copyWith(currentFloor: floor);
  }

  // ============================================================
  // NODE OPERATIONS
  // ============================================================

  /// Adds a new node at the specified position
  NavNode addNode(LatLng position, {String? buildingId}) {
    final node = NavNode(
      id: IdGenerator.generateNodeId(),
      position: position,
      buildingId: buildingId,
      floor: state.currentFloor,
      accessible: state.createAccessible,
      type: state.nodeTypeToCreate,
    );

    _graphService.addNode(node);
    state = state.copyWith(hasUnsavedChanges: true);

    return node;
  }

  /// Moves a node to a new position
  void moveNode(String nodeId, LatLng newPosition) {
    if (!_graphService.hasNode(nodeId)) return;

    _graphService.moveNode(nodeId, newPosition);
    state = state.copyWith(hasUnsavedChanges: true);
  }

  /// Deletes a node and its edges
  void deleteNode(String nodeId) {
    if (!_graphService.hasNode(nodeId)) return;

    _graphService.removeNode(nodeId);
    state = state.copyWith(
      hasUnsavedChanges: true,
      clearSelectedNodeId: state.selectedNodeId == nodeId,
    );
  }

  /// Updates an existing node
  void updateNode(NavNode node) {
    _graphService.updateNode(node);
    state = state.copyWith(hasUnsavedChanges: true);
  }

  // ============================================================
  // SELECTION
  // ============================================================

  /// Selects a node
  void selectNode(String nodeId) {
    if (state.currentTool == EditorTool.connectNodes) {
      _handleConnectNodeTap(nodeId);
    } else {
      state = state.copyWith(selectedNodeId: nodeId);
    }
  }

  /// Clears the current selection
  void clearSelection() {
    state = state.copyWith(
      clearSelectedNodeId: true,
      clearConnectFromNodeId: true,
    );
  }

  /// Handles tapping a node in connect mode
  void _handleConnectNodeTap(String nodeId) {
    if (state.connectFromNodeId == null) {
      // First tap - set as source
      state = state.copyWith(connectFromNodeId: nodeId);
    } else if (state.connectFromNodeId == nodeId) {
      // Same node - cancel
      state = state.copyWith(clearConnectFromNodeId: true);
    } else {
      // Second tap - create connection
      connectNodes(state.connectFromNodeId!, nodeId);
      state = state.copyWith(clearConnectFromNodeId: true);
    }
  }

  // ============================================================
  // EDGE OPERATIONS
  // ============================================================

  /// Connects two nodes
  void connectNodes(String nodeIdA, String nodeIdB) {
    if (!_graphService.hasNode(nodeIdA) || !_graphService.hasNode(nodeIdB)) {
      return;
    }

    _graphService.connectNodes(nodeIdA, nodeIdB);
    state = state.copyWith(hasUnsavedChanges: true);
  }

  /// Disconnects two nodes
  void disconnectNodes(String nodeIdA, String nodeIdB) {
    _graphService.disconnectNodes(nodeIdA, nodeIdB);
    state = state.copyWith(hasUnsavedChanges: true);
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  /// Saves all changes
  Future<void> saveChanges() async {
    await _persistenceService.saveGraph(_graphService);
    state = state.copyWith(hasUnsavedChanges: false);
  }

  /// Discards unsaved changes by reloading from storage
  Future<void> discardChanges() async {
    await _persistenceService.loadGraph(_graphService);
    state = state.copyWith(
      hasUnsavedChanges: false,
      clearSelectedNodeId: true,
      clearConnectFromNodeId: true,
    );
  }

  /// Exports the graph to JSON
  String exportToJson() {
    return _persistenceService.exportToJson(_graphService);
  }

  // ============================================================
  // MAP INTERACTION HANDLERS
  // ============================================================

  /// Handles long press on the map
  void handleMapLongPress(LatLng position) {
    if (!state.isAdminMode) return;

    switch (state.currentTool) {
      case EditorTool.addNode:
        addNode(position);
        break;
      case EditorTool.deleteNode:
        // Long press on empty space - do nothing
        break;
      default:
        break;
    }
  }

  /// Handles tap on the map
  void handleMapTap(LatLng position) {
    if (!state.isAdminMode) return;

    // Clear selection when tapping empty space
    if (state.currentTool != EditorTool.connectNodes) {
      clearSelection();
    }
  }

  /// Handles tap on a node marker
  void handleNodeTap(String nodeId) {
    if (!state.isAdminMode) {
      // In view mode, selecting nodes is handled by NavigationController
      return;
    }

    switch (state.currentTool) {
      case EditorTool.deleteNode:
        // Single tap to select, confirm dialog should be shown by UI
        selectNode(nodeId);
        break;
      case EditorTool.moveNode:
        selectNode(nodeId);
        break;
      case EditorTool.connectNodes:
        selectNode(nodeId); // This triggers the connection logic
        break;
      default:
        selectNode(nodeId);
        break;
    }
  }

  /// Handles node long press
  void handleNodeLongPress(String nodeId) {
    if (!state.isAdminMode) return;

    if (state.currentTool == EditorTool.deleteNode) {
      // Long press on node - this should trigger delete confirmation
      selectNode(nodeId);
    }
  }

  /// Handles node drag (for move mode)
  void handleNodeDrag(String nodeId, LatLng newPosition) {
    if (!state.isAdminMode || state.currentTool != EditorTool.moveNode) return;

    if (state.selectedNodeId == nodeId) {
      moveNode(nodeId, newPosition);
    }
  }
}
