import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
          SnackBar(
            content: Text(next.actionMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFF4D6D),
          ),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'My Deliveries',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: const Color(0xFF647C72),
          indicatorColor: const Color(0xFF2E7D32),
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: 'Available (${ordersState.pendingDeliveries.length})'),
            Tab(text: 'Active (${ordersState.activeDeliveries.length})'),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F8F4),
                ),
                child: const Icon(Icons.inbox_outlined, size: 28, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              Text(
                'No Available Jobs',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              ),
              const SizedBox(height: 4),
              Text(
                'New delivery requests will appear here dynamically.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildPendingCard(pending[index]),
    );
  }

  Widget _buildPendingCard(DeliveryOrder delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.orderId.substring(0, 8)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF23312B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${(delivery.deliveryFee ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (delivery.farmer != null)
              _buildLocationRow('Pickup', delivery.farmer!.name, delivery.pickupAddress?.fullAddress ?? 'Farm address'),
            if (delivery.customer != null) ...[
              const SizedBox(height: 8),
              _buildLocationRow('Drop', delivery.customer!.name, delivery.deliveryAddress?.fullAddress ?? 'Customer address'),
            ],
            const Divider(height: 24, color: Color(0xFFF3F3F3)),
            Row(
              children: [
                if (delivery.distance != null) ...[
                  const Icon(Icons.straighten_outlined, size: 14, color: Color(0xFF647C72)),
                  const SizedBox(width: 4),
                  Text(
                    '${delivery.distance!.toStringAsFixed(1)} km',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
                if (delivery.estimatedDeliveryTime != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF647C72)),
                  const SizedBox(width: 4),
                  Text(
                    '${delivery.estimatedDeliveryTime}',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showRejectDialog(delivery),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Reject',
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _acceptDelivery(delivery.id),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Accept Job',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
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
    final isPickup = label == 'Pickup';
    final dotColor = isPickup ? const Color(0xFF2E7D32) : const Color(0xFF219EBC);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 28, color: const Color(0xFFECECEC)),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF8D99AE), fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
              ),
              Text(
                address,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveList(List<DeliveryOrder> active) {
    if (active.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F8F4),
                ),
                child: const Icon(Icons.local_shipping_outlined, size: 28, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Jobs',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Accept available requests above to begin deliveries.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: active.length,
      itemBuilder: (context, index) => _buildActiveCard(active[index]),
    );
  }

  Widget _buildActiveCard(DeliveryOrder delivery) {
    final statusColor = _getStatusColor(delivery.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/delivery-detail', extra: delivery.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${delivery.orderId.substring(0, 8)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF23312B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(delivery.status).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(color: statusColor, fontWeight: FontWeight.w800, fontSize: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (delivery.deliveryAddress != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF219EBC)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          delivery.deliveryAddress!.fullAddress,
                          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const Divider(height: 20, color: Color(0xFFF3F3F3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${(delivery.deliveryFee ?? 0).toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32), fontSize: 14),
                    ),
                    Icon(Icons.chevron_right, color: statusColor, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _acceptDelivery(String deliveryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Job Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to accept this crop delivery?', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Accept Job', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
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
        title: Text('Reject Job Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Please provide a reason for rejecting this job:', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(deliveryOrdersProvider.notifier).rejectDelivery(
                    delivery.id,
                    reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                  );
            },
            child: Text('Reject Job', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return const Color(0xFFE28C43);
      case DeliveryOrderStatus.accepted:
        return const Color(0xFF219EBC);
      case DeliveryOrderStatus.pickedUp:
        return const Color(0xFF8338EC);
      case DeliveryOrderStatus.outForDelivery:
        return const Color(0xFF8338EC);
      case DeliveryOrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return const Color(0xFFFF4D6D);
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
