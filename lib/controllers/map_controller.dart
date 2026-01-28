import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/map_constants.dart';

/// State for the map controller
class MapState {
  /// The flutter_map controller
  final fm.MapController? controller;

  /// Current center position
  final LatLng center;

  /// Whether the map is ready
  final bool isReady;

  /// Current zoom level
  final double zoom;

  /// Whether to show the ground overlay
  final bool showOverlay;

  /// Ground overlay transparency
  final double overlayTransparency;

  const MapState({
    this.controller,
    this.center = const LatLng(10.357459, 76.212722),
    this.isReady = false,
    this.zoom = 17.0,
    this.showOverlay = true,
    this.overlayTransparency = 0.0,
  });

  MapState copyWith({
    fm.MapController? controller,
    LatLng? center,
    bool? isReady,
    double? zoom,
    bool? showOverlay,
    double? overlayTransparency,
  }) {
    return MapState(
      controller: controller ?? this.controller,
      center: center ?? this.center,
      isReady: isReady ?? this.isReady,
      zoom: zoom ?? this.zoom,
      showOverlay: showOverlay ?? this.showOverlay,
      overlayTransparency: overlayTransparency ?? this.overlayTransparency,
    );
  }
}

/// Controller for map rendering and camera operations.
///
/// This controller is responsible for:
/// - Managing the flutter_map controller
/// - Camera position and zoom
/// - Ground overlay visibility
///
/// It does NOT manage navigation logic or node data.
class MapController extends StateNotifier<MapState> {
  MapController() : super(const MapState());

  /// Called when the map is created
  void onMapCreated(fm.MapController controller) {
    state = state.copyWith(controller: controller, isReady: true);
  }

  /// Called when camera position changes
  void onCameraMove(LatLng center, double zoom) {
    state = state.copyWith(center: center, zoom: zoom);
  }

  /// Moves the camera to a specific position
  void moveTo(LatLng target, {double? zoom}) {
    if (state.controller == null) return;

    state.controller!.move(target, zoom ?? state.zoom);
  }

  /// Moves the camera to show the campus bounds
  void showCampusBounds() {
    if (state.controller == null) return;

    state.controller!.fitCamera(
      fm.CameraFit.bounds(
        bounds: MapConstants.campusBounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  /// Moves the camera to the campus center
  void centerOnCampus() {
    moveTo(MapConstants.campusCenter, zoom: MapConstants.defaultZoom);
  }

  /// Zooms in
  void zoomIn() {
    if (state.controller == null) return;

    final newZoom = (state.zoom + 1).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );

    state.controller!.move(state.center, newZoom);
  }

  /// Zooms out
  void zoomOut() {
    if (state.controller == null) return;

    final newZoom = (state.zoom - 1).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );

    state.controller!.move(state.center, newZoom);
  }

  /// Toggles ground overlay visibility
  void toggleOverlay() {
    state = state.copyWith(showOverlay: !state.showOverlay);
  }

  /// Sets overlay transparency
  void setOverlayTransparency(double transparency) {
    state = state.copyWith(overlayTransparency: transparency.clamp(0.0, 1.0));
  }

  /// Fits the camera to show specific bounds
  void fitBounds(fm.LatLngBounds bounds, {double padding = 50}) {
    if (state.controller == null) return;

    state.controller!.fitCamera(
      fm.CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(padding)),
    );
  }

  /// Gets the current visible region
  fm.LatLngBounds? getVisibleRegion() {
    if (state.controller == null) return null;
    return state.controller!.camera.visibleBounds;
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}
