import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryOrdersProvider.notifier).loadDelivery(widget.deliveryId));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(deliveryOrdersProvider);
    final delivery = ordersState.selectedDelivery;

    ref.listen<DeliveryOrdersState>(deliveryOrdersProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!), backgroundColor: Colors.green),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(delivery != null ? 'Order #${delivery.orderId}' : 'Delivery Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ordersState.isLoading || delivery == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusTimeline(delivery),
                  const SizedBox(height: 16),
                  _buildAddresses(delivery),
                  const SizedBox(height: 16),
                  if (delivery.items != null && delivery.items!.isNotEmpty)
                    _buildItems(delivery),
                  const SizedBox(height: 16),
                  _buildOrderSummary(delivery),
                  if (delivery.specialInstructions != null &&
                      delivery.specialInstructions!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSpecialInstructions(delivery),
                  ],
                  const SizedBox(height: 20),
                  _buildActionButtons(delivery, ordersState),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusTimeline(DeliveryOrder delivery) {
    final steps = [
      _TimelineStep('Assigned', 'Order assigned to you', delivery.assignedAt != null, Icons.assignment),
      _TimelineStep('Accepted', 'Delivery accepted', delivery.acceptedAt != null, Icons.check_circle),
      _TimelineStep('Picked Up', 'Picked up from farmer', delivery.pickedUpAt != null, Icons.inventory_2),
      _TimelineStep('On the Way', 'Delivering to customer', delivery.status == DeliveryOrderStatus.outForDelivery, Icons.local_shipping),
      _TimelineStep('Delivered', 'Successfully delivered', delivery.deliveredAt != null, Icons.flag),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        step.icon,
                        size: 20,
                        color: step.completed ? Colors.green : Colors.grey[400],
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: step.completed ? Colors.green : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: step.completed ? Colors.black : Colors.grey,
                            ),
                          ),
                          Text(
                            step.subtitle,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddresses(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (delivery.pickupAddress != null || delivery.farmer != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.store, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        Text(delivery.farmer?.name ?? 'Farmer',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(delivery.pickupAddress?.fullAddress ?? 'Farm address',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        if (delivery.farmer?.phone.isNotEmpty == true)
                          Text(delivery.farmer!.phone,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
            if (delivery.deliveryAddress != null || delivery.customer != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Drop-off', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        Text(delivery.customer?.name ?? 'Customer',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(delivery.deliveryAddress?.fullAddress ?? 'Customer address',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        if (delivery.customer?.phone.isNotEmpty == true)
                          Text(delivery.customer!.phone,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items (${delivery.items!.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...delivery.items!.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.quantity}x ${item.name}',
                            style: const TextStyle(fontSize: 14)),
                      ),
                      Text('₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (delivery.orderSummary != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('₹${delivery.orderSummary!.subtotal.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee', style: TextStyle(color: Colors.green)),
                Text('₹${(delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '₹${(delivery.orderSummary?.total ?? delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            if (delivery.rating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Customer Rating: '),
                  ...List.generate(5, (index) => Icon(
                        index < (delivery.rating ?? 0) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Special Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(delivery.specialInstructions!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DeliveryOrder delivery, DeliveryOrdersState ordersState) {
    final buttons = <Widget>[];

    switch (delivery.status) {
      case DeliveryOrderStatus.accepted:
        buttons.add(_buildActionButton(
          'Pick Up from Farmer',
          Icons.inventory_2,
          Colors.teal,
          ordersState.isPerformingAction,
          () => ref.read(deliveryOrdersProvider.notifier).markPickedUp(delivery.id),
        ));
        break;
      case DeliveryOrderStatus.pickedUp:
        buttons.add(_buildActionButton(
          'Start Delivery',
          Icons.local_shipping,
          Colors.purple,
          ordersState.isPerformingAction,
          () => ref.read(deliveryOrdersProvider.notifier).startDelivery(delivery.id),
        ));
        break;
      case DeliveryOrderStatus.outForDelivery:
        buttons.add(_buildActionButton(
          'Verify OTP & Complete',
          Icons.lock_open,
          Colors.green,
          ordersState.isPerformingAction,
          () => _showOtpDialog(delivery.id),
        ));
        break;
      default:
        break;
    }

    if (delivery.status == DeliveryOrderStatus.outForDelivery) {
      buttons.add(const SizedBox(height: 12));
      buttons.add(OutlinedButton.icon(
        onPressed: () => context.push('/delivery-navigation', extra: delivery),
        icon: const Icon(Icons.map),
        label: const Text('Open Navigation'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
          minimumSize: const Size(double.infinity, 48),
        ),
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(children: buttons);
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showOtpDialog(String deliveryId) {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Delivery OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ask the customer for their 6-digit OTP:'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final otp = _otpController.text.trim();
              if (otp.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid 6-digit OTP'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(context);
              final success = await ref.read(deliveryOrdersProvider.notifier).verifyOtp(deliveryId, otp);
              if (success && mounted) {
                await ref.read(deliveryOrdersProvider.notifier).completeDelivery(deliveryId);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Verify & Complete'),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool completed;
  final IconData icon;

  _TimelineStep(this.title, this.subtitle, this.completed, this.icon);
}
