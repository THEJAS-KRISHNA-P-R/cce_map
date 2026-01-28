import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart' as p;

import '../../core/constants/app_constants.dart';
import '../../providers/navigation_provider.dart';

/// 360° Panorama Viewer widget for immersive 3D navigation.
///
/// Displays panoramic WebP images from Firebase Storage with:
/// - CachedNetworkImage for instant return visits
/// - Hero animation for smooth 2D-to-3D transitions
/// - Navigation controls to move between connected nodes
class PanoramaViewer extends StatefulWidget {
  /// The ID of the node whose panorama to display
  final String nodeId;

  /// Callback when user wants to exit panorama mode
  final VoidCallback? onExit;

  const PanoramaViewer({super.key, required this.nodeId, this.onExit});

  @override
  State<PanoramaViewer> createState() => _PanoramaViewerState();
}

class _PanoramaViewerState extends State<PanoramaViewer> {
  late NavigationProvider _navProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navProvider = p.Provider.of<NavigationProvider>(context);

    // Prefetch next node panoramas
    _prefetchNextNodes();
  }

  void _prefetchNextNodes() {
    final urls = _navProvider.getPrefetchUrls();
    for (final url in urls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _navProvider.getPanoramaUrl(widget.nodeId);
    final node = _navProvider.getNode(widget.nodeId);

    if (url == null) {
      return _buildErrorState('No panorama available for this node.');
    }

    return Stack(
      children: [
        // Panorama image with Hero animation
        Hero(
          tag: 'panorama_${widget.nodeId}',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => _buildErrorState(
                'Failed to load panorama. Check your connection.',
              ),
            ),
          ),
        ),

        // Top navigation bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(200), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onExit ?? () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.nodeId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (node != null)
                          Text(
                            'Floor ${node.floor} · ${node.type.name.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom navigation controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(200), Colors.transparent],
                ),
              ),
              child: _buildNavigationControls(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationControls() {
    final currentNode = _navProvider.getNode(widget.nodeId);
    if (currentNode == null) return const SizedBox.shrink();

    final connectedNodes = currentNode.edges
        .map((id) => _navProvider.getNode(id))
        .whereType<dynamic>()
        .toList();

    if (connectedNodes.isEmpty) {
      return const Center(
        child: Text(
          'No connected paths',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: connectedNodes.map((node) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToNode(node.id),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(node.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(200),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToNode(String nodeId) {
    _navProvider.selectNode(nodeId);

    // Use cross-fade transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PanoramaViewer(nodeId: nodeId, onExit: widget.onExit);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.panorama_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (widget.onExit != null)
            ElevatedButton(
              onPressed: widget.onExit,
              child: const Text('Return to Map'),
            ),
        ],
      ),
    );
  }
}
