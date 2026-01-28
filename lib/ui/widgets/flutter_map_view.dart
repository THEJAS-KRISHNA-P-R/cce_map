import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;

import '../../core/constants/app_constants.dart';
import '../../core/constants/map_constants.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';

/// The main flutter_map widget displaying the campus overlay, nodes, and paths.
class FlutterMapView extends ConsumerStatefulWidget {
  const FlutterMapView({super.key});

  @override
  ConsumerState<FlutterMapView> createState() => _FlutterMapViewState();
}

class _FlutterMapViewState extends ConsumerState<FlutterMapView> {
  final fm.MapController _mapController = fm.MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorControllerProvider);
    final navState = ref.watch(navigationControllerProvider);
    final graphService = ref.watch(navGraphServiceProvider);
    final navProvider = p.Provider.of<NavigationProvider>(context);

    return fm.FlutterMap(
      mapController: _mapController,
      options: fm.MapOptions(
        initialCenter: MapConstants.campusCenter,
        initialZoom: MapConstants.defaultZoom,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
        interactionOptions: const fm.InteractionOptions(
          flags: fm.InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          if (editorState.isAdminMode) {
            ref.read(editorControllerProvider.notifier).handleMapTap(point);
          }
        },
        onLongPress: (tapPosition, point) {
          if (editorState.isAdminMode) {
            ref
                .read(editorControllerProvider.notifier)
                .handleMapLongPress(point);
          }
        },
      ),
      children: [
        // Base layer: MapTiler streets-v2
        fm.TileLayer(
          urlTemplate: MapConstants.maptilerTileUrl,
          userAgentPackageName: 'com.cce.map',
          maxZoom: 22,
        ),

        // TODO: Campus overlay - uncomment when campus.png is available
        // fm.OverlayImageLayer(
        //   overlayImages: [
        //     fm.OverlayImage(
        //       bounds: MapConstants.campusBounds,
        //       imageProvider: const AssetImage(MapConstants.campusMapAsset),
        //     ),
        //   ],
        // ),

        // Path polylines (edges and routes)
        fm.PolylineLayer(
          polylines: _buildPolylines(graphService, editorState, navState),
        ),

        // Node markers
        fm.MarkerLayer(
          markers: _buildNodeMarkers(
            graphService,
            editorState,
            navState,
            navProvider,
          ),
        ),
      ],
    );
  }

  /// Builds polylines for edges and routes.
  List<fm.Polyline> _buildPolylines(
    NavGraphService graphService,
    EditorState editorState,
    NavigationState navState,
  ) {
    final polylines = <fm.Polyline>[];

    // Draw all edges in editor mode
    if (editorState.isAdminMode) {
      for (final (fromId, toId) in graphService.edges) {
        final fromNode = graphService.getNode(fromId);
        final toNode = graphService.getNode(toId);

        if (fromNode != null && toNode != null) {
          polylines.add(
            fm.Polyline(
              points: [fromNode.position, toNode.position],
              color: AppConstants.edgePreviewColor.withAlpha(150),
              strokeWidth: AppConstants.edgePreviewWidth,
            ),
          );
        }
      }
    }

    // Draw current route
    if (navState.currentRoute != null && navState.currentRoute!.isValid) {
      polylines.add(
        fm.Polyline(
          points: navState.currentRoute!.polylinePoints,
          color: AppConstants.routeColor,
          strokeWidth: AppConstants.routeWidth,
          borderColor: Colors.white,
          borderStrokeWidth: 2,
        ),
      );
    }

    return polylines;
  }

  /// Builds markers for all nodes.
  List<fm.Marker> _buildNodeMarkers(
    NavGraphService graphService,
    EditorState editorState,
    NavigationState navState,
    NavigationProvider navProvider,
  ) {
    final markers = <fm.Marker>[];

    for (final node in graphService.nodes) {
      final isSelected =
          editorState.selectedNodeId == node.id ||
          navProvider.selectedNodeId == node.id;
      final isConnectFrom = editorState.connectFromNodeId == node.id;
      final isStart = navState.startNodeId == node.id;
      final isEnd = navState.endNodeId == node.id;

      Color markerColor;
      double markerSize;

      if (isStart) {
        markerColor = AppConstants.startNodeColor;
        markerSize = 24;
      } else if (isEnd) {
        markerColor = AppConstants.endNodeColor;
        markerSize = 24;
      } else if (isSelected || isConnectFrom) {
        markerColor = AppConstants.selectedNodeColor;
        markerSize = 20;
      } else {
        markerColor = _getNodeColor(node.type);
        markerSize = 16;
      }

      markers.add(
        fm.Marker(
          point: node.position,
          width: markerSize * 1.5,
          height: markerSize * 1.5,
          child: GestureDetector(
            onTap: () =>
                _handleNodeTap(node.id, editorState.isAdminMode, navProvider),
            child: Container(
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isStart || isEnd
                  ? Icon(
                      isStart ? Icons.play_arrow : Icons.flag,
                      color: Colors.white,
                      size: markerSize * 0.7,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// Handles tap on a node.
  void _handleNodeTap(
    String nodeId,
    bool isAdminMode,
    NavigationProvider navProvider,
  ) {
    if (isAdminMode) {
      ref.read(editorControllerProvider.notifier).handleNodeTap(nodeId);

      // Show delete confirmation if in delete mode
      final editorState = ref.read(editorControllerProvider);
      if (editorState.currentTool == EditorTool.deleteNode &&
          editorState.selectedNodeId == nodeId) {
        _showDeleteConfirmation(nodeId);
      }
    } else {
      // Select node and optionally enter panorama mode
      navProvider.selectNode(nodeId);
      ref.read(navigationControllerProvider.notifier).handleNodeTap(nodeId);

      // Prefetch panorama images for next nodes
      _prefetchPanoramaImages(navProvider);
    }
  }

  /// Prefetches panorama images for the next nodes.
  void _prefetchPanoramaImages(NavigationProvider navProvider) {
    final urls = navProvider.getPrefetchUrls();
    for (final url in urls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  /// Shows delete confirmation dialog.
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Gets color for a node type.
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
}
