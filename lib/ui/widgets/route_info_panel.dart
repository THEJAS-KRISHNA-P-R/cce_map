import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

/// Panel displaying route information when a route is active.
class RouteInfoPanel extends ConsumerWidget {
  const RouteInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(currentRouteProvider);
    final navState = ref.watch(navigationControllerProvider);

    if (route == null || !route.isValid) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Route Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Swap direction button
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Swap Start/End',
                      onPressed: () {
                        ref
                            .read(navigationControllerProvider.notifier)
                            .swapStartEnd();
                      },
                    ),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear Route',
                      onPressed: () {
                        ref
                            .read(navigationControllerProvider.notifier)
                            .clearRoute();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // Route details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: route.distanceText,
                ),
                _InfoItem(
                  icon: Icons.timer,
                  label: 'Est. Time',
                  value: route.timeText,
                ),
                _InfoItem(
                  icon: Icons.route,
                  label: 'Nodes',
                  value: '${route.nodeCount}',
                ),
              ],
            ),

            // Floor information
            if (route.floorTransitions > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.stairs, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${route.floorTransitions} floor transition(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  const Spacer(),
                  Text(
                    'Floor ${route.startFloor} → ${route.endFloor}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],

            // Accessibility indicator
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    route.isAccessible ? Icons.accessible : Icons.warning,
                    size: 16,
                    color: route.isAccessible ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    route.isAccessible
                        ? 'Wheelchair accessible route'
                        : 'May not be wheelchair accessible',
                    style: TextStyle(
                      fontSize: 12,
                      color: route.isAccessible ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Start Navigation button
            if (!navState.isNavigating) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(navigationControllerProvider.notifier)
                      .startNavigation();
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Start Navigation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],

            // Accessibility filter toggle
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Only accessible routes',
                  style: TextStyle(fontSize: 12),
                ),
                Switch(
                  value: navState.requireAccessible,
                  onChanged: (value) {
                    ref
                        .read(navigationControllerProvider.notifier)
                        .setRequireAccessible(value);
                  },
                ),
              ],
            ),

            // Error message
            if (navState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        navState.errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
