import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart'; // Import this to get all providers
import '../../controllers/controllers.dart'; // Import this for editorControllerProvider type if needed

/// Dialog for editing a node's panorama URL.
class NodePanoDialog extends StatefulWidget {
  final String nodeId;
  final String? initialUrl;

  const NodePanoDialog({super.key, required this.nodeId, this.initialUrl});

  /// Shows the dialog
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    String nodeId,
  ) async {
    final graphService = ref.read(navGraphServiceProvider);
    final node = graphService.getNode(nodeId);
    if (node == null) return;

    await showDialog(
      context: context,
      builder: (context) =>
          NodePanoDialog(nodeId: nodeId, initialUrl: node.panoUrl),
    );
  }

  @override
  State<NodePanoDialog> createState() => _NodePanoDialogState();
}

class _NodePanoDialogState extends State<NodePanoDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Panorama Image'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the image filename OR full URL.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Example: canteen_to_st_marys.webp\nOR: https://example.com/image.jpg',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Image Filename or URL',
                border: const OutlineInputBorder(),
                hintText: 'e.g. library.webp or https://...',
                prefixIcon: const Icon(Icons.image),
              ),
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear the URL
            Consumer(
              builder: (context, ref, _) {
                ref
                    .read(editorControllerProvider.notifier)
                    .setNodePanoUrl(widget.nodeId, null);
                return const SizedBox.shrink();
              },
            );
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, _) {
            return FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(editorControllerProvider.notifier)
                      .setNodePanoUrl(widget.nodeId, _controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            );
          },
        ),
      ],
    );
  }
}
