import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';

/// Admin toolbar for map editing operations.
///
/// Provides tool selection, node type selection, and action buttons.
class AdminToolbar extends ConsumerWidget {
  const AdminToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorControllerProvider);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'EDIT MODE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tool selection
            const Text(
              'Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _ToolButton(
                  icon: Icons.add_location,
                  label: 'Add',
                  isSelected: editorState.currentTool == EditorTool.addNode,
                  onPressed: () => ref
                      .read(editorControllerProvider.notifier)
                      .setTool(EditorTool.addNode),
                ),
                _ToolButton(
                  icon: Icons.open_with,
                  label: 'Move',
                  isSelected: editorState.currentTool == EditorTool.moveNode,
                  onPressed: () => ref
                      .read(editorControllerProvider.notifier)
                      .setTool(EditorTool.moveNode),
                ),
                _ToolButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  isSelected: editorState.currentTool == EditorTool.deleteNode,
                  onPressed: () => ref
                      .read(editorControllerProvider.notifier)
                      .setTool(EditorTool.deleteNode),
                ),
                _ToolButton(
                  icon: Icons.link,
                  label: 'Connect',
                  isSelected:
                      editorState.currentTool == EditorTool.connectNodes,
                  onPressed: () => ref
                      .read(editorControllerProvider.notifier)
                      .setTool(EditorTool.connectNodes),
                ),
              ],
            ),

            const Divider(height: 16),

            // Node type selection (only in add mode)
            if (editorState.currentTool == EditorTool.addNode) ...[
              const Text(
                'Node Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: NodeType.values.map((type) {
                  return _TypeChip(
                    label: type.name,
                    isSelected: editorState.nodeTypeToCreate == type,
                    color: _getTypeColor(type),
                    onPressed: () => ref
                        .read(editorControllerProvider.notifier)
                        .setNodeType(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Accessibility toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: editorState.createAccessible,
                    onChanged: (value) => ref
                        .read(editorControllerProvider.notifier)
                        .setAccessible(value ?? true),
                  ),
                  const Text('Accessible', style: TextStyle(fontSize: 12)),
                ],
              ),

              // Floor selector
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Floor: ', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () => ref
                        .read(editorControllerProvider.notifier)
                        .setCurrentFloor(editorState.currentFloor - 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  Text(
                    '${editorState.currentFloor}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => ref
                        .read(editorControllerProvider.notifier)
                        .setCurrentFloor(editorState.currentFloor + 1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ],

            // Connection mode indicator
            if (editorState.currentTool == EditorTool.connectNodes) ...[
              const Text(
                'Connect Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                editorState.connectFromNodeId == null
                    ? 'Tap first node'
                    : 'Tap second node to connect',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              if (editorState.connectFromNodeId != null)
                TextButton(
                  onPressed: () => ref
                      .read(editorControllerProvider.notifier)
                      .clearSelection(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
            ],

            // Help text based on tool
            const SizedBox(height: 8),
            _buildHelpText(editorState.currentTool),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText(EditorTool tool) {
    String text;
    switch (tool) {
      case EditorTool.view:
        text = 'Select a tool above';
      case EditorTool.addNode:
        text = 'Long-press map to add node';
      case EditorTool.moveNode:
        text = 'Tap node, then drag to move';
      case EditorTool.deleteNode:
        text = 'Tap node to select, tap again to delete';
      case EditorTool.connectNodes:
        text = 'Tap two nodes to connect them';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.blue)),
        ],
      ),
    );
  }

  Color _getTypeColor(NodeType type) {
    switch (type) {
      case NodeType.outdoor:
        return Colors.blue;
      case NodeType.indoor:
        return Colors.green;
      case NodeType.stairs:
      case NodeType.elevator:
        return Colors.orange;
      case NodeType.entrance:
        return Colors.purple;
      case NodeType.poi:
        return Colors.pink;
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.blue.withAlpha((0.2 * 255).round())
          : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onPressed;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha((0.2 * 255).round())
              : Colors.grey.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.withAlpha((0.3 * 255).round()),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
