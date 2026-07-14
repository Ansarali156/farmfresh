import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryHistoryScreen extends ConsumerStatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  ConsumerState<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends ConsumerState<DeliveryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryHistoryProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(deliveryHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Delivery History',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () => ref.read(deliveryHistoryProvider.notifier).loadHistory(),
              child: historyState.orders.isEmpty
                  ? Center(
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
                              child: const Icon(Icons.history, size: 28, color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No delivery history',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed delivery jobs will appear here for your ledger reference.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: historyState.orders.length,
                      itemBuilder: (context, index) {
                        final order = historyState.orders[index];
                        return _buildHistoryCard(order);
                      },
                    ),
            ),
    );
  }

  Widget _buildHistoryCard(DeliveryOrder order) {
    final statusColor = _getStatusColor(order.status);
    String dateStr = '';
    try {
      if (order.deliveredAt != null) {
        final parsed = DateTime.parse(order.deliveredAt!);
        dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(parsed);
      } else if (order.assignedAt != null) {
        final parsed = DateTime.parse(order.assignedAt!);
        dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(parsed);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          onTap: () => context.push('/delivery-detail', extra: order.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.orderId.substring(0, 8)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(order.status).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 8, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order.deliveryAddress?.fullAddress != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF647C72)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.deliveryAddress!.fullAddress,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
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
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF8D99AE), fontWeight: FontWeight.w500),
                      ),
                    Row(
                      children: [
                        Text(
                          '₹${(order.deliveryFee ?? 0).toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32), fontSize: 13),
                        ),
                        if (order.rating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Color(0xFFFFB703), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${order.rating}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return const Color(0xFFFF4D6D);
      default:
        return const Color(0xFF647C72);
    }
  }

  String _getStatusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
      default:
        return status.apiValue;
    }
  }
}
