import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../core/theme/delivery_theme.dart';

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
    final state = ref.watch(deliveryHistoryProvider);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        title: Text(
          'Completed Deliveries History',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: DeliveryTheme.navyDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: DeliveryTheme.orangePrimary))
          : RefreshIndicator(
              color: DeliveryTheme.orangePrimary,
              onRefresh: () => ref.read(deliveryHistoryProvider.notifier).loadHistory(),
              child: state.orders.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                        Center(
                          child: Text(
                            'No completed deliveries yet.',
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) {
                        final delivery = state.orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: DeliveryTheme.cardDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: DeliveryTheme.navyDark),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DeliveryTheme.statusDelivered.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'DELIVERED',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: DeliveryTheme.statusDelivered,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed at ${delivery.deliveredAt ?? 'Recently'}',
                                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
