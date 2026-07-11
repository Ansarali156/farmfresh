import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryOrdersScreen extends ConsumerStatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  ConsumerState<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends ConsumerState<DeliveryOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(deliveryOrdersProvider);

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
        title: const Text('My Deliveries'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Available (${ordersState.pendingDeliveries.length})'),
            Tab(text: 'Active (${ordersState.activeDeliveries.length})'),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryOrdersProvider.notifier).loadDeliveries(),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingList(ordersState.pendingDeliveries),
                  _buildActiveList(ordersState.activeDeliveries),
                ],
              ),
            ),
    );
  }

  Widget _buildPendingList(List<DeliveryOrder> pending) {
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending deliveries', style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text('New deliveries will appear here', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildPendingCard(pending[index]),
    );
  }

  Widget _buildPendingCard(DeliveryOrder delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${delivery.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${(delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (delivery.farmer != null)
              _buildLocationRow('Pickup', delivery.farmer!.name, delivery.pickupAddress?.fullAddress ?? 'Farm address'),
            if (delivery.customer != null) ...[
              const SizedBox(height: 8),
              _buildLocationRow('Drop', delivery.customer!.name, delivery.deliveryAddress?.fullAddress ?? 'Customer address'),
            ],
            if (delivery.distance != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${delivery.distance!.toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (delivery.estimatedDeliveryTime != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${delivery.estimatedDeliveryTime}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(delivery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptDelivery(delivery.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String name, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              label == 'Pickup' ? Icons.store : Icons.home,
              size: 16,
              color: label == 'Pickup' ? Colors.green : Colors.blue,
            ),
            Container(width: 2, height: 20, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(address, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveList(List<DeliveryOrder> active) {
    if (active.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active deliveries', style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text('Accept a delivery to get started', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: active.length,
      itemBuilder: (context, index) => _buildActiveCard(active[index]),
    );
  }

  Widget _buildActiveCard(DeliveryOrder delivery) {
    final statusColor = _getStatusColor(delivery.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/delivery-detail', extra: delivery.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${delivery.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(delivery.status),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (delivery.deliveryAddress != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        delivery.deliveryAddress!.fullAddress ?? 'Delivery address',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${(delivery.deliveryFee ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Icon(Icons.chevron_right, color: statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptDelivery(String deliveryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Delivery'),
        content: const Text('Are you sure you want to accept this delivery?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deliveryOrdersProvider.notifier).acceptDelivery(deliveryId);
    }
  }

  void _showRejectDialog(DeliveryOrder delivery) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(deliveryOrdersProvider.notifier).rejectDelivery(
                    delivery.id,
                    reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                  );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Colors.orange;
      case DeliveryOrderStatus.accepted:
        return Colors.blue;
      case DeliveryOrderStatus.pickedUp:
        return Colors.teal;
      case DeliveryOrderStatus.outForDelivery:
        return Colors.purple;
      case DeliveryOrderStatus.delivered:
        return Colors.green;
      case DeliveryOrderStatus.cancelled:
        return Colors.red;
      case DeliveryOrderStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return 'Pending';
      case DeliveryOrderStatus.accepted:
        return 'Accepted';
      case DeliveryOrderStatus.pickedUp:
        return 'Picked Up';
      case DeliveryOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
    }
  }
}
