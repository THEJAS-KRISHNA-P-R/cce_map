import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../models/models.dart';

/// Bottom panel showing turn-by-turn navigation guidance.
///
/// Displays current step, next step preview, progress, and controls.
class NavigationGuidancePanel extends ConsumerWidget {
  const NavigationGuidancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationControllerProvider);

    if (!navState.isNavigating || navState.currentRoute == null) {
      return const SizedBox.shrink();
    }

    final currentStep = navState.currentStep;
    final remainingDist = navState.remainingDistance;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            // Previous button
            IconButton(
              onPressed: navState.currentStepIndex > 0
                  ? () => ref
                        .read(navigationControllerProvider.notifier)
                        .goToPreviousStep()
                  : null,
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),

            // Instruction
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentStep != null) ...[
                    Text(
                      currentStep.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_formatDistance(remainingDist)} • Step ${navState.currentStepIndex + 1}/${navState.currentRoute!.stepCount}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Next button
            IconButton(
              onPressed: () => ref
                  .read(navigationControllerProvider.notifier)
                  .advanceToNextStep(),
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              color: Colors.blue,
            ),

            // Stop button (small x)
            IconButton(
              onPressed: () => ref
                  .read(navigationControllerProvider.notifier)
                  .stopNavigation(),
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
