import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/delivery_model.dart';

class DeliveryNavigationScreen extends StatelessWidget {
  final DeliveryOrder delivery;

  const DeliveryNavigationScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final destination = delivery.deliveryAddress;
    final address = destination?.fullAddress ?? 'Delivery location';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _callCustomer(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Map View', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(address, textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(),
                      icon: const Icon(Icons.directions),
                      label: const Text('Open in Google Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomInfo(context),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (delivery.distance != null) ...[
                Icon(Icons.straighten, color: Colors.grey[600], size: 18),
                const SizedBox(width: 4),
                Text('${delivery.distance!.toStringAsFixed(1)} km', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 20),
              ],
              if (delivery.estimatedDeliveryTime != null) ...[
                Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                const SizedBox(width: 4),
                Text('${delivery.estimatedDeliveryTime}', style: TextStyle(color: Colors.grey[600])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (delivery.customer != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivery.customer!.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(delivery.customer!.phone,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _callCustomer(context),
                  icon: const Icon(Icons.phone, color: Colors.green),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleMaps(),
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps() async {
    final address = delivery.deliveryAddress?.fullAddress ?? '';
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _callCustomer(BuildContext context) {
    final phone = delivery.customer?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available'), backgroundColor: Colors.orange),
      );
      return;
    }
    launchUrl(Uri.parse('tel:$phone'));
  }
}
