import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/providers.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/map_constants.dart';

/// The main map widget displaying the campus overlay, nodes, and paths.
class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  String? _draggingNodeId;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final editorState = ref.watch(editorControllerProvider);
    final navState = ref.watch(navigationControllerProvider);
    final graphService = ref.watch(navGraphServiceProvider);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: MapConstants.campusCenter,
        zoom: MapConstants.defaultZoom,
      ),
      onMapCreated: (controller) {
        ref.read(mapControllerProvider.notifier).onMapCreated(controller);
      },
      onCameraMove: (position) {
        ref.read(mapControllerProvider.notifier).onCameraMove(position);
      },
      onTap: (position) {
        if (editorState.isAdminMode) {
          ref.read(editorControllerProvider.notifier).handleMapTap(position);
        }
      },
      onLongPress: (position) {
        if (editorState.isAdminMode) {
          ref
              .read(editorControllerProvider.notifier)
              .handleMapLongPress(position);
          // Force rebuild to show new node
          setState(() {});
        }
      },
      groundOverlays: _buildGroundOverlays(mapState),
      markers: _buildMarkers(graphService, editorState, navState),
      polylines: _buildPolylines(graphService, editorState, navState),
      mapType: MapType.normal,
      minMaxZoomPreference: const MinMaxZoomPreference(
        MapConstants.minZoom,
        MapConstants.maxZoom,
      ),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  Set<GroundOverlay> _buildGroundOverlays(MapState mapState) {
    // TODO: GroundOverlay is not well-supported on web platform
    // The campus.png overlay will be visible on Android/iOS
    // For web, we'll just show the base Google Map
    return {};
  }

  Set<Marker> _buildMarkers(
    NavGraphService graphService,
    EditorState editorState,
    NavigationState navState,
  ) {
    final markers = <Marker>{};

    for (final node in graphService.nodes) {
      final isSelected = editorState.selectedNodeId == node.id;
      final isConnectFrom = editorState.connectFromNodeId == node.id;
      final isStart = navState.startNodeId == node.id;
      final isEnd = navState.endNodeId == node.id;
      final isDragging = _draggingNodeId == node.id;

      Color markerColor;
      if (isStart) {
        markerColor = AppConstants.startNodeColor;
      } else if (isEnd) {
        markerColor = AppConstants.endNodeColor;
      } else if (isSelected || isConnectFrom) {
        markerColor = AppConstants.selectedNodeColor;
      } else {
        markerColor = _getNodeColor(node.type);
      }

      markers.add(
        Marker(
          markerId: MarkerId(node.id),
          position: node.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(_colorToHue(markerColor)),
          draggable:
              editorState.isAdminMode &&
              editorState.currentTool == EditorTool.moveNode &&
              (isSelected || isDragging),
          onTap: () => _handleNodeTap(node.id, editorState.isAdminMode),
          onDrag: (newPosition) {
            _draggingNodeId = node.id;
          },
          onDragEnd: (newPosition) {
            ref
                .read(editorControllerProvider.notifier)
                .moveNode(node.id, newPosition);
            _draggingNodeId = null;
            setState(() {});
          },
          infoWindow: InfoWindow(
            title: node.id,
            snippet: 'Floor: ${node.floor}, Type: ${node.type.name}',
          ),
        ),
      );
    }

    return markers;
  }

  void _handleNodeTap(String nodeId, bool isAdminMode) {
    if (isAdminMode) {
      ref.read(editorControllerProvider.notifier).handleNodeTap(nodeId);

      // Show delete confirmation if in delete mode
      final editorState = ref.read(editorControllerProvider);
      if (editorState.currentTool == EditorTool.deleteNode &&
          editorState.selectedNodeId == nodeId) {
        _showDeleteConfirmation(nodeId);
      }
    } else {
      ref.read(navigationControllerProvider.notifier).handleNodeTap(nodeId);
    }
    setState(() {});
  }

  void _showDeleteConfirmation(String nodeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Node?'),
        content: Text('Are you sure you want to delete node $nodeId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(editorControllerProvider.notifier).deleteNode(nodeId);
              Navigator.pop(context);
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Set<Polyline> _buildPolylines(
    NavGraphService graphService,
    EditorState editorState,
    NavigationState navState,
  ) {
    final polylines = <Polyline>{};

    // Draw all edges in editor mode
    if (editorState.isAdminMode) {
      for (final (fromId, toId) in graphService.edges) {
        final fromNode = graphService.getNode(fromId);
        final toNode = graphService.getNode(toId);

        if (fromNode != null && toNode != null) {
          polylines.add(
            Polyline(
              polylineId: PolylineId('edge_${fromId}_$toId'),
              points: [fromNode.position, toNode.position],
              color: AppConstants.edgePreviewColor,
              width: AppConstants.edgePreviewWidth.toInt(),
            ),
          );
        }
      }
    }

    // Draw current route
    if (navState.currentRoute != null && navState.currentRoute!.isValid) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('current_route'),
          points: navState.currentRoute!.polylinePoints,
          color: AppConstants.routeColor,
          width: AppConstants.routeWidth.toInt(),
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }

  Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.outdoor:
        return AppConstants.outdoorNodeColor;
      case NodeType.indoor:
        return AppConstants.indoorNodeColor;
      case NodeType.stairs:
      case NodeType.elevator:
        return AppConstants.verticalNodeColor;
      case NodeType.entrance:
        return AppConstants.entranceNodeColor;
      case NodeType.poi:
        return AppConstants.poiNodeColor;
    }
  }

  double _colorToHue(Color color) {
    // Convert color to HSL hue (0-360)
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }
}
