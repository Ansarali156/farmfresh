import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapZoomControls extends StatelessWidget {
  final MapController mapController;
  final double zoomStep;

  const MapZoomControls({
    super.key,
    required this.mapController,
    this.zoomStep = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              final zoom = mapController.camera.zoom + zoomStep;
              mapController.move(mapController.camera.center, zoom);
            },
            tooltip: 'Zoom In',
          ),
          const Divider(height: 1, indent: 8, endIndent: 8),
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black87),
            onPressed: () {
              final zoom = mapController.camera.zoom - zoomStep;
              mapController.move(mapController.camera.center, zoom);
            },
            tooltip: 'Zoom Out',
          ),
        ],
      ),
    );
  }
}
