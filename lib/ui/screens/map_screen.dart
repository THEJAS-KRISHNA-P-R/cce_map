import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/flutter_map_view.dart';
import '../widgets/admin_toolbar.dart';
import '../widgets/route_info_panel.dart';
import '../widgets/location_selector.dart';
import '../widgets/navigation_guidance_panel.dart';
import '../widgets/panorama_thumbnail.dart';
import '../widgets/panorama_viewer.dart';
import '../../core/utils/geojson_exporter.dart';

/// Main map screen for the indoor navigation app.
///
/// Displays the campus map with navigation nodes, paths, and
/// provides admin editing capabilities.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final isAdminMode = ref.watch(isAdminModeProvider);
    final navState = ref.watch(navigationControllerProvider);
    // Navigation Provider for visual mode state
    final navProvider = ref.watch(navigationProviderProvider);
    final isVisualMode = navProvider.isVisualMode;
    final visualNodeId = navProvider.selectedNodeId;

    // Show PanoramaViewer if in visual mode
    if (isVisualMode && visualNodeId != null) {
      return Scaffold(
        body: PanoramaViewer(
          nodeId: visualNodeId,
          onExit: () => ref.read(navigationProviderProvider).exitPanoramaMode(),
        ),
      );
    }

    final hasRoute = navState.hasRoute;
    final isNavigating = navState.isNavigating;
    final editorState = ref.watch(editorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CCE Indoor Navigation'),
        actions: [
          // Admin mode toggle
          IconButton(
            icon: Icon(
              isAdminMode ? Icons.edit_off : Icons.edit,
              color: isAdminMode ? Colors.orange : null,
            ),
            tooltip: isAdminMode ? 'Exit Admin Mode' : 'Enter Admin Mode',
            onPressed: () {
              ref.read(editorControllerProvider.notifier).toggleAdminMode();
            },
          ),
          // Save button (only in admin mode with changes)
          if (isAdminMode && editorState.hasUnsavedChanges)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Changes',
              onPressed: () async {
                await ref.read(editorControllerProvider.notifier).saveChanges();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes saved')),
                  );
                }
              },
            ),
          // Export GeoJSON button (only in admin mode)
          if (isAdminMode)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Save to GeoJSON File',
              onPressed: () async {
                final graphService = ref.read(navGraphServiceProvider);
                final success = await GeoJsonExporter.saveToFile(graphService);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Saved to assets/data/cce_test.geojson'
                            : '❌ Save failed - is the server running?',
                      ),
                    ),
                  );
                }
              },
            ),
          // Clear route button
          if (hasRoute)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Route',
              onPressed: () {
                ref.read(navigationControllerProvider.notifier).clearRoute();
              },
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800; // Basic breakpoint

          return Stack(
            children: [
              // Main map view
              const FlutterMapView(),

              // Admin toolbar (when in admin mode)
              if (isAdminMode)
                const Positioned(left: 16, top: 16, child: AdminToolbar()),

              // Location selector (when no route and not in admin mode)
              if (!hasRoute && !isAdminMode)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: LocationSelector(),
                ),

              // Route info panel (when route exists but not navigating, and not in admin mode)
              if (hasRoute && !isNavigating && !isAdminMode)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: RouteInfoPanel(),
                ),

              // Navigation guidance panel (when actively navigating)
              if (isNavigating && !isAdminMode)
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: NavigationGuidancePanel(),
                ),

              // Unsaved changes indicator
              if (isAdminMode && editorState.hasUnsavedChanges)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Unsaved changes',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

              // Street View Thumbnail (Moved to Top of Stack)
              Positioned(
                right: 16,
                // Adjust bottom padding based on active panels (Guidance/RouteInfo)
                // Guidance panel is approx 100-120 height, so we clear it.
                bottom: (isNavigating || hasRoute)
                    ? 140
                    : (isDesktop ? 32 : 90),
                child: Consumer(
                  builder: (context, ref, _) {
                    final isAdminMode = ref.watch(isAdminModeProvider);
                    final navState = ref.watch(navigationControllerProvider);
                    final graphService = ref.watch(navGraphServiceProvider);

                    // In admin mode, use editor selection. In normal mode, use navigation provider selection.
                    final String? selectedNodeId = isAdminMode
                        ? ref.watch(selectedNodeIdProvider)
                        : ref.watch(navigationProviderProvider).selectedNodeId;

                    // Determine effective node ID.
                    // Prioritize explicit selection. Fallback to current nav step if nothing selected.
                    String? effectiveNodeId = selectedNodeId;
                    if (effectiveNodeId == null &&
                        navState.isNavigating &&
                        navState.startNodeId != null) {
                      effectiveNodeId = navState.startNodeId;
                    }

                    if (effectiveNodeId == null) return const SizedBox.shrink();

                    final node = graphService.getNode(effectiveNodeId);
                    if (node == null) return const SizedBox.shrink();

                    // Check if node has a panorama
                    if (node.panoUrl == null || node.panoUrl!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return PanoramaThumbnail(
                      node: node,
                      onTap: () {
                        // Push PanoramaViewer as a new route for Hero transition
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                                  return PanoramaViewer(
                                    nodeId: node.id,
                                    onExit: () => Navigator.of(
                                      context,
                                    ).pop(), // Pop to return
                                  );
                                },
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context, isAdminMode),
    );
  }

  Widget? _buildFAB(BuildContext context, bool isAdminMode) {
    if (isAdminMode) {
      return null;
    }

    return FloatingActionButton(
      heroTag: 'center_fab',
      onPressed: () {
        ref.read(mapControllerProvider.notifier).centerOnCampus();
      },
      tooltip: 'Center on Campus',
      child: const Icon(Icons.my_location),
    );
  }
}
