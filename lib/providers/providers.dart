import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../controllers/controllers.dart';
import 'navigation_provider.dart';

// ============================================================
// SERVICE PROVIDERS
// ============================================================

/// Provider for the navigation graph service
final navGraphServiceProvider = Provider<NavGraphService>((ref) {
  return NavGraphService();
});

/// Provider for the persistence service
final persistenceServiceProvider = Provider<PersistenceService>((ref) {
  return PersistenceService();
});

/// Provider for the routing service
final routingServiceProvider = Provider<RoutingService>((ref) {
  final graphService = ref.watch(navGraphServiceProvider);
  return RoutingService(graphService);
});

// ============================================================
// CONTROLLER PROVIDERS
// ============================================================

/// Provider for the map controller
final mapControllerProvider = StateNotifierProvider<MapController, MapState>((
  ref,
) {
  return MapController();
});

/// Provider for the editor controller
final editorControllerProvider =
    StateNotifierProvider<EditorController, EditorState>((ref) {
      final graphService = ref.watch(navGraphServiceProvider);
      final persistenceService = ref.watch(persistenceServiceProvider);
      return EditorController(graphService, persistenceService);
    });

/// Provider for the navigation controller
final navigationControllerProvider =
    StateNotifierProvider<NavigationController, NavigationState>((ref) {
      final routingService = ref.watch(routingServiceProvider);
      final graphService = ref.watch(navGraphServiceProvider);
      return NavigationController(routingService, graphService);
    });

// ============================================================
// DATA PROVIDERS
// ============================================================

/// Provider for the list of all nodes
final nodesProvider = Provider<List<NavNode>>((ref) {
  final graphService = ref.watch(navGraphServiceProvider);
  return graphService.nodes;
});

/// Provider for the list of all buildings
final buildingsProvider = Provider<List<Building>>((ref) {
  final graphService = ref.watch(navGraphServiceProvider);
  return graphService.buildings;
});

/// Provider for the current route
final currentRouteProvider = Provider<RouteResult?>((ref) {
  final navState = ref.watch(navigationControllerProvider);
  return navState.currentRoute;
});

/// Provider for checking if admin mode is enabled
final isAdminModeProvider = Provider<bool>((ref) {
  final editorState = ref.watch(editorControllerProvider);
  return editorState.isAdminMode;
});

/// Provider for the currently selected node ID
final selectedNodeIdProvider = Provider<String?>((ref) {
  final editorState = ref.watch(editorControllerProvider);
  return editorState.selectedNodeId;
});

/// Provider for the navigation provider (for accessing nodes and panorama data)
final navigationProviderProvider = ChangeNotifierProvider<NavigationProvider>((
  ref,
) {
  return NavigationProvider();
});

/// Provider for the current editor tool
final currentToolProvider = Provider<EditorTool>((ref) {
  final editorState = ref.watch(editorControllerProvider);
  return editorState.currentTool;
});

// ============================================================
// INITIALIZATION PROVIDER
// ============================================================

/// Provider for app initialization
final initializationProvider = FutureProvider<void>((ref) async {
  final persistenceService = ref.read(persistenceServiceProvider);
  final graphService = ref.read(navGraphServiceProvider);

  // Initialize persistence
  await persistenceService.initialize();

  // Try to load from local storage first
  if (persistenceService.hasLocalData()) {
    await persistenceService.loadGraph(graphService);
  } else {
    // Load from assets if no local data
    await persistenceService.loadFromAssets(graphService);
  }
});
