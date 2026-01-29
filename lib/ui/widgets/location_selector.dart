import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../models/models.dart';

/// Widget for selecting start and destination locations.
///
/// Allows users to pick nodes from the navigation graph.
class LocationSelector extends ConsumerStatefulWidget {
  const LocationSelector({super.key});

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  String? _selectedStartId;
  String? _selectedEndId;
  bool _forceExpanded = false;

  @override
  Widget build(BuildContext context) {
    final navProvider = ref.watch(navigationProviderProvider);
    final navState = ref.watch(navigationControllerProvider);
    final nodes = navProvider.nodes;

    // Update local state from controller
    _selectedStartId = navState.startNodeId;
    _selectedEndId = navState.endNodeId;

    // Determine if we should show the full card
    final bool isExpanded =
        _forceExpanded || _selectedStartId != null || _selectedEndId != null;

    if (!isExpanded) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton.extended(
          heroTag: 'directions_fab',
          onPressed: () {
            setState(() {
              _forceExpanded = true;
            });
          },
          icon: const Icon(Icons.directions),
          label: const Text('Directions'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text(
              'Plan Your Route',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _forceExpanded = false;
                  // Also clear route if user closes? Maybe not.
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Start location selector
                _LocationDropdown(
                  label: 'Start Location',
                  icon: Icons.my_location,
                  value: _selectedStartId,
                  nodes: nodes,
                  onChanged: (nodeId) {
                    if (nodeId != null) {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .setStartNode(nodeId);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Swap button
                Center(
                  child: IconButton(
                    onPressed:
                        (_selectedStartId != null && _selectedEndId != null)
                        ? () {
                            ref
                                .read(navigationControllerProvider.notifier)
                                .swapStartEnd();
                          }
                        : null,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Swap Start and Destination',
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),

                // Destination selector
                _LocationDropdown(
                  label: 'Destination',
                  icon: Icons.place,
                  value: _selectedEndId,
                  nodes: nodes,
                  onChanged: (nodeId) {
                    if (nodeId != null) {
                      ref
                          .read(navigationControllerProvider.notifier)
                          .setEndNode(nodeId);
                    }
                  },
                ),

                // Error message
                if (navState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            navState.errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Clear button
                if (_selectedStartId != null || _selectedEndId != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        ref
                            .read(navigationControllerProvider.notifier)
                            .clearRoute();
                        setState(() => _forceExpanded = false);
                      },
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear Selection'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<NavNode> nodes;
  final ValueChanged<String?>? onChanged;

  const _LocationDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.nodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: nodes.map((node) {
            return DropdownMenuItem<String>(
              value: node.id,
              child: Text(
                _getNodeDisplayName(node),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getNodeDisplayName(NavNode node) {
    // Use metadata name if available, otherwise use node ID
    if (node.metadata.containsKey('name')) {
      return node.metadata['name'] as String;
    }

    // Create a friendly name from node type and position
    final typeStr = node.type.name.toUpperCase();
    final lat = node.position.latitude.toStringAsFixed(4);
    final lng = node.position.longitude.toStringAsFixed(4);
    return '$typeStr ($lat, $lng)';
  }
}
