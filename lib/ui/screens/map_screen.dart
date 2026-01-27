import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/map_view.dart';
import '../widgets/admin_toolbar.dart';
import '../widgets/route_info_panel.dart';

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
    final hasRoute = ref.watch(currentRouteProvider)?.isValid ?? false;
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
      body: Stack(
        children: [
          // Main map view
          const MapView(),

          // Admin toolbar (when in admin mode)
          if (isAdminMode)
            const Positioned(left: 16, top: 16, child: AdminToolbar()),

          // Route info panel (when route is active)
          if (hasRoute && !isAdminMode)
            const Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: RouteInfoPanel(),
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
        ],
      ),
      floatingActionButton: _buildFAB(context, isAdminMode),
    );
  }

  Widget? _buildFAB(BuildContext context, bool isAdminMode) {
    if (isAdminMode) {
      return null; // No FAB in admin mode
    }

    return FloatingActionButton(
      onPressed: () {
        ref.read(mapControllerProvider.notifier).centerOnCampus();
      },
      tooltip: 'Center on Campus',
      child: const Icon(Icons.my_location),
    );
  }
}
