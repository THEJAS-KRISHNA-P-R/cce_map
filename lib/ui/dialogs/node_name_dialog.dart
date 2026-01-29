import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

/// Dialog for naming a navigation node.
///
/// Allows users to set a friendly name for a node in admin mode.
class NodeNameDialog extends ConsumerStatefulWidget {
  final String nodeId;
  final String? currentName;

  const NodeNameDialog({super.key, required this.nodeId, this.currentName});

  /// Shows the node name dialog
  static Future<void> show(
    BuildContext context,
    String nodeId,
    String? currentName,
  ) {
    return showDialog(
      context: context,
      builder: (context) =>
          NodeNameDialog(nodeId: nodeId, currentName: currentName),
    );
  }

  @override
  ConsumerState<NodeNameDialog> createState() => _NodeNameDialogState();
}

class _NodeNameDialogState extends ConsumerState<NodeNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Name This Node'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Node ID: ${widget.nodeId}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Node Name',
              hintText: 'e.g., Main Entrance, Library, Cafeteria',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _saveName(),
          ),
        ],
      ),
      actions: [
        // Clear button
        if (widget.currentName != null && widget.currentName!.isNotEmpty)
          TextButton(
            onPressed: () {
              ref
                  .read(editorControllerProvider.notifier)
                  .setNodeName(widget.nodeId, '');
              Navigator.of(context).pop();
            },
            child: const Text('Clear Name'),
          ),
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Save button
        ElevatedButton(onPressed: _saveName, child: const Text('Save')),
      ],
    );
  }

  void _saveName() {
    final name = _controller.text.trim();
    ref
        .read(editorControllerProvider.notifier)
        .setNodeName(widget.nodeId, name);
    Navigator.of(context).pop();
  }
}
