import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/map_constants.dart';

/// State for the map controller
class MapState {
  /// The Google Maps controller
  final GoogleMapController? controller;

  /// Current camera position
  final CameraPosition cameraPosition;

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
    this.cameraPosition = const CameraPosition(
      target: LatLng(12.9716, 77.5946),
      zoom: MapConstants.defaultZoom,
    ),
    this.isReady = false,
    this.zoom = MapConstants.defaultZoom,
    this.showOverlay = true,
    this.overlayTransparency = MapConstants.overlayTransparency,
  });

  MapState copyWith({
    GoogleMapController? controller,
    CameraPosition? cameraPosition,
    bool? isReady,
    double? zoom,
    bool? showOverlay,
    double? overlayTransparency,
  }) {
    return MapState(
      controller: controller ?? this.controller,
      cameraPosition: cameraPosition ?? this.cameraPosition,
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
/// - Managing the Google Maps controller
/// - Camera position and zoom
/// - Ground overlay visibility
///
/// It does NOT manage navigation logic or node data.
class MapController extends StateNotifier<MapState> {
  MapController() : super(const MapState());

  /// Called when the map is created
  void onMapCreated(GoogleMapController controller) {
    state = state.copyWith(controller: controller, isReady: true);
  }

  /// Called when camera position changes
  void onCameraMove(CameraPosition position) {
    state = state.copyWith(cameraPosition: position, zoom: position.zoom);
  }

  /// Moves the camera to a specific position
  Future<void> moveTo(LatLng target, {double? zoom}) async {
    if (state.controller == null) return;

    await state.controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom ?? state.zoom),
      ),
    );
  }

  /// Moves the camera to show the campus bounds
  Future<void> showCampusBounds() async {
    if (state.controller == null) return;

    await state.controller!.animateCamera(
      CameraUpdate.newLatLngBounds(MapConstants.campusBounds, 50),
    );
  }

  /// Moves the camera to the campus center
  Future<void> centerOnCampus() async {
    await moveTo(MapConstants.campusCenter, zoom: MapConstants.defaultZoom);
  }

  /// Zooms in
  Future<void> zoomIn() async {
    if (state.controller == null) return;

    final newZoom = (state.zoom + 1).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );

    await state.controller!.animateCamera(CameraUpdate.zoomTo(newZoom));
  }

  /// Zooms out
  Future<void> zoomOut() async {
    if (state.controller == null) return;

    final newZoom = (state.zoom - 1).clamp(
      MapConstants.minZoom,
      MapConstants.maxZoom,
    );

    await state.controller!.animateCamera(CameraUpdate.zoomTo(newZoom));
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
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 50}) async {
    if (state.controller == null) return;

    await state.controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  /// Gets the current visible region
  Future<LatLngBounds?> getVisibleRegion() async {
    if (state.controller == null) return null;
    return await state.controller!.getVisibleRegion();
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}
