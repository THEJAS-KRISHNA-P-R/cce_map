import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/services.dart';

/// State for navigation
class NavigationState {
  /// Start node for routing
  final String? startNodeId;

  /// End node for routing
  final String? endNodeId;

  /// Calculated route result
  final RouteResult? currentRoute;

  /// Whether route is being calculated
  final bool isCalculating;

  /// Whether to require accessible routes
  final bool requireAccessible;

  /// Error message if routing failed
  final String? errorMessage;

  const NavigationState({
    this.startNodeId,
    this.endNodeId,
    this.currentRoute,
    this.isCalculating = false,
    this.requireAccessible = false,
    this.errorMessage,
  });

  NavigationState copyWith({
    String? startNodeId,
    bool clearStartNodeId = false,
    String? endNodeId,
    bool clearEndNodeId = false,
    RouteResult? currentRoute,
    bool clearRoute = false,
    bool? isCalculating,
    bool? requireAccessible,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NavigationState(
      startNodeId: clearStartNodeId ? null : (startNodeId ?? this.startNodeId),
      endNodeId: clearEndNodeId ? null : (endNodeId ?? this.endNodeId),
      currentRoute: clearRoute ? null : (currentRoute ?? this.currentRoute),
      isCalculating: isCalculating ?? this.isCalculating,
      requireAccessible: requireAccessible ?? this.requireAccessible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Whether a route is active
  bool get hasRoute => currentRoute != null && currentRoute!.isValid;

  /// Whether start and end are selected
  bool get hasStartAndEnd => startNodeId != null && endNodeId != null;
}

/// Controller for navigation and routing.
///
/// This controller handles:
/// - Start/end node selection
/// - Route calculation
/// - Accessibility preferences
class NavigationController extends StateNotifier<NavigationState> {
  final RoutingService _routingService;
  final NavGraphService _graphService;

  NavigationController(this._routingService, this._graphService)
    : super(const NavigationState());

  // ============================================================
  // NODE SELECTION
  // ============================================================

  /// Sets the start node
  void setStartNode(String nodeId) {
    if (!_graphService.hasNode(nodeId)) return;

    state = state.copyWith(
      startNodeId: nodeId,
      clearRoute: true,
      clearError: true,
    );

    _tryCalculateRoute();
  }

  /// Sets the end node
  void setEndNode(String nodeId) {
    if (!_graphService.hasNode(nodeId)) return;

    state = state.copyWith(
      endNodeId: nodeId,
      clearRoute: true,
      clearError: true,
    );

    _tryCalculateRoute();
  }

  /// Handles tap on a node - toggles between start/end selection
  void handleNodeTap(String nodeId) {
    if (state.startNodeId == null) {
      setStartNode(nodeId);
    } else if (state.startNodeId == nodeId) {
      // Tapped same node - clear start
      clearStart();
    } else if (state.endNodeId == null) {
      setEndNode(nodeId);
    } else if (state.endNodeId == nodeId) {
      // Tapped same end node - clear end
      clearEnd();
    } else {
      // Both set, tapped different node - set as new end
      setEndNode(nodeId);
    }
  }

  /// Clears the start node
  void clearStart() {
    state = state.copyWith(clearStartNodeId: true, clearRoute: true);
  }

  /// Clears the end node
  void clearEnd() {
    state = state.copyWith(clearEndNodeId: true, clearRoute: true);
  }

  /// Clears both start and end nodes
  void clearRoute() {
    state = state.copyWith(
      clearStartNodeId: true,
      clearEndNodeId: true,
      clearRoute: true,
      clearError: true,
    );
  }

  /// Swaps start and end nodes
  void swapStartEnd() {
    if (state.startNodeId == null && state.endNodeId == null) return;

    state = state.copyWith(
      startNodeId: state.endNodeId,
      endNodeId: state.startNodeId,
      clearRoute: true,
    );

    _tryCalculateRoute();
  }

  // ============================================================
  // ROUTING
  // ============================================================

  /// Sets accessibility requirement
  void setRequireAccessible(bool require) {
    state = state.copyWith(requireAccessible: require, clearRoute: true);

    _tryCalculateRoute();
  }

  /// Attempts to calculate the route if both nodes are selected
  void _tryCalculateRoute() {
    if (!state.hasStartAndEnd) return;

    calculateRoute();
  }

  /// Calculates the route between start and end nodes
  void calculateRoute() {
    if (state.startNodeId == null || state.endNodeId == null) {
      state = state.copyWith(
        errorMessage: 'Please select start and end points',
      );
      return;
    }

    state = state.copyWith(isCalculating: true, clearError: true);

    try {
      final route = _routingService.findRoute(
        state.startNodeId!,
        state.endNodeId!,
        requireAccessible: state.requireAccessible,
      );

      if (route.isValid) {
        state = state.copyWith(currentRoute: route, isCalculating: false);
      } else {
        state = state.copyWith(
          clearRoute: true,
          isCalculating: false,
          errorMessage: 'No route found between selected points',
        );
      }
    } catch (e) {
      state = state.copyWith(
        clearRoute: true,
        isCalculating: false,
        errorMessage: 'Error calculating route: $e',
      );
    }
  }

  // ============================================================
  // POSITION UPDATES (Future: PDR, AI localization)
  // ============================================================

  /// Interface for updating user position from external sources
  /// (AI photo localization, PDR sensors, QR codes, etc.)
  void updateUserPosition(String nearestNodeId) {
    // Future implementation: update user position marker
    // and potentially recalculate route
  }

  /// Interface for AI-based position estimation
  void updatePositionFromAI(double lat, double lng) {
    // Future implementation: find nearest node and update position
  }

  // ============================================================
  // QUERY HELPERS
  // ============================================================

  /// Gets the start node
  NavNode? get startNode => state.startNodeId != null
      ? _graphService.getNode(state.startNodeId!)
      : null;

  /// Gets the end node
  NavNode? get endNode =>
      state.endNodeId != null ? _graphService.getNode(state.endNodeId!) : null;
}
