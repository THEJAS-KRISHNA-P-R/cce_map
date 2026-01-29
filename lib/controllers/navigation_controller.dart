import 'package:flutter/foundation.dart';
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

  /// Whether turn-by-turn navigation is active
  final bool isNavigating;

  /// Current step index in navigation (0-based)
  final int currentStepIndex;

  const NavigationState({
    this.startNodeId,
    this.endNodeId,
    this.currentRoute,
    this.isCalculating = false,
    this.requireAccessible = false,
    this.errorMessage,
    this.isNavigating = false,
    this.currentStepIndex = 0,
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
    bool? isNavigating,
    int? currentStepIndex,
  }) {
    return NavigationState(
      startNodeId: clearStartNodeId ? null : (startNodeId ?? this.startNodeId),
      endNodeId: clearEndNodeId ? null : (endNodeId ?? this.endNodeId),
      currentRoute: clearRoute ? null : (currentRoute ?? this.currentRoute),
      isCalculating: isCalculating ?? this.isCalculating,
      requireAccessible: requireAccessible ?? this.requireAccessible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isNavigating: isNavigating ?? this.isNavigating,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }

  /// Whether a route is active
  bool get hasRoute => currentRoute != null && currentRoute!.isValid;

  /// Whether start and end are selected
  bool get hasStartAndEnd => startNodeId != null && endNodeId != null;

  /// Get current navigation step
  NavigationStep? get currentStep {
    if (!isNavigating || currentRoute == null) return null;
    return currentRoute!.getStep(currentStepIndex);
  }

  /// Get next navigation step
  NavigationStep? get nextStep {
    if (!isNavigating || currentRoute == null) return null;
    return currentRoute!.getStep(currentStepIndex + 1);
  }

  /// Get remaining distance from current step
  double get remainingDistance {
    if (!isNavigating || currentRoute == null) return 0;
    return currentRoute!.getRemainingDistance(currentStepIndex);
  }

  /// Get navigation progress (0.0 to 1.0)
  double get navigationProgress {
    if (!isNavigating || currentRoute == null) return 0;
    return currentRoute!.getProgressPercentage(currentStepIndex);
  }
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
    debugPrint('[NavigationController] setStartNode: $nodeId');
    debugPrint(
      '[NavigationController] hasNode: ${_graphService.hasNode(nodeId)}',
    );
    debugPrint(
      '[NavigationController] total nodes in graph: ${_graphService.nodes.length}',
    );
    if (!_graphService.hasNode(nodeId)) {
      debugPrint('[NavigationController] Node not found in graph service!');
      return;
    }

    state = state.copyWith(
      startNodeId: nodeId,
      clearRoute: true,
      clearError: true,
    );
    debugPrint(
      '[NavigationController] Start node set successfully to: ${state.startNodeId}',
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
    debugPrint('[NavigationController] handleNodeTap: $nodeId');
    debugPrint(
      '[NavigationController] current startNodeId: ${state.startNodeId}',
    );
    debugPrint('[NavigationController] current endNodeId: ${state.endNodeId}');

    if (state.startNodeId == null) {
      debugPrint('[NavigationController] Setting start node...');
      setStartNode(nodeId);
    } else if (state.startNodeId == nodeId) {
      // Tapped same node - clear start
      debugPrint(
        '[NavigationController] Clearing start node (same node tapped)',
      );
      clearStart();
    } else if (state.endNodeId == null) {
      debugPrint('[NavigationController] Setting end node...');
      setEndNode(nodeId);
    } else if (state.endNodeId == nodeId) {
      // Tapped same end node - clear end
      debugPrint('[NavigationController] Clearing end node (same node tapped)');
      clearEnd();
    } else {
      // Both set, tapped different node - set as new end
      debugPrint('[NavigationController] Replacing end node...');
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
  // NAVIGATION CONTROLS
  // ============================================================

  /// Starts turn-by-turn navigation for the current route
  void startNavigation() {
    if (!state.hasRoute) {
      debugPrint('[NavigationController] Cannot start navigation - no route');
      return;
    }

    debugPrint('[NavigationController] Starting navigation');
    state = state.copyWith(isNavigating: true, currentStepIndex: 0);
  }

  /// Stops turn-by-turn navigation
  void stopNavigation() {
    debugPrint('[NavigationController] Stopping navigation');
    state = state.copyWith(isNavigating: false, currentStepIndex: 0);
  }

  /// Advances to the next navigation step
  void advanceToNextStep() {
    if (!state.isNavigating || state.currentRoute == null) return;

    final currentStep = state.currentStep;
    if (currentStep == null) return;

    final nextIndex = state.currentStepIndex + 1;
    if (nextIndex >= state.currentRoute!.stepCount) {
      // Reached destination
      debugPrint('[NavigationController] Reached destination');
      stopNavigation();
      return;
    }

    debugPrint('[NavigationController] Advancing to step $nextIndex');

    // Update start location to the destination of the current step
    // This keeps the user's position synchronized with their progress
    final newStartNodeId = currentStep.toNodeId;

    state = state.copyWith(
      currentStepIndex: nextIndex,
      startNodeId: newStartNodeId,
    );
  }

  /// Goes back to the previous navigation step
  void goToPreviousStep() {
    if (!state.isNavigating || state.currentRoute == null) return;

    final prevIndex = state.currentStepIndex - 1;
    if (prevIndex < 0) {
      debugPrint('[NavigationController] Already at first step');
      return;
    }

    debugPrint('[NavigationController] Going back to step $prevIndex');

    // Update start location to the start of the previous step
    final previousStep = state.currentRoute!.getStep(prevIndex);
    if (previousStep != null) {
      state = state.copyWith(
        currentStepIndex: prevIndex,
        startNodeId: previousStep.fromNodeId,
      );
    } else {
      state = state.copyWith(currentStepIndex: prevIndex);
    }
  }

  /// Recalculates route from current step
  void recalculateFromCurrentStep() {
    if (!state.isNavigating || state.currentRoute == null) return;

    final currentStep = state.currentStep;
    if (currentStep == null) return;

    // Use the "to" node of current step as new start
    final newStartId = currentStep.toNodeId;
    if (state.endNodeId == null) return;

    debugPrint('[NavigationController] Recalculating from $newStartId');

    // Update start node and recalculate
    state = state.copyWith(
      startNodeId: newStartId,
      clearRoute: true,
      isNavigating: false,
      currentStepIndex: 0,
    );

    _tryCalculateRoute();
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
