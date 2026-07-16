import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/delivery_model.dart';

class DeliveryNavigationScreen extends ConsumerStatefulWidget {
  final DeliveryOrder delivery;

  const DeliveryNavigationScreen({super.key, required this.delivery});

  @override
  ConsumerState<DeliveryNavigationScreen> createState() => _DeliveryNavigationScreenState();
}

class _DeliveryNavigationScreenState extends ConsumerState<DeliveryNavigationScreen> {
  int _currentStep = 0;

  final List<String> _navigationSteps = [
    'Turn right onto Main Highway (Heading towards Swapna Bharat Farms)',
    'Keep left at the fork, follow signs for Guntur Industrial Area',
    'Arrived at Swapna Bharat Farms. Collect package from farmer.',
    'Head southwest toward Customer location',
    'Turn left onto Market Street, destination is on your right',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Navigation Route'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Simulated Map Panel
          Expanded(
            child: Container(
              color: Colors.grey[850],
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.navigation, size: 80, color: Colors.greenAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Simulating Active GPS Route...',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.directions, color: Colors.greenAccent, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NEXT MANEUVER',
                                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _navigationSteps[_currentStep],
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Route Details Panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REMAINING DISTANCE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${((5 - _currentStep) * 0.7).toStringAsFixed(1)} km',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_currentStep < _navigationSteps.length - 1) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(_currentStep < _navigationSteps.length - 1 ? 'Simulate Drive' : 'Close Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 24),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.delivery.deliveryAddress?.street ?? 'Drop-off location details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
