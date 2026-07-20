import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../core/theme/delivery_theme.dart';

class DeliveryOrdersScreen extends ConsumerStatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  ConsumerState<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends ConsumerState<DeliveryOrdersScreen> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.alt_route_rounded, color: DeliveryTheme.orangePrimary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Route Assignments',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: DeliveryTheme.navyDark,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DeliveryTheme.orangePrimary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Available Jobs'),
                  const SizedBox(width: 6),
                  if (ordersState.pendingDeliveries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: DeliveryTheme.orangePrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${ordersState.pendingDeliveries.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Active Runs'),
                  const SizedBox(width: 6),
                  if (ordersState.activeDeliveries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${ordersState.activeDeliveries.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator(color: DeliveryTheme.orangePrimary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobsList(ordersState.pendingDeliveries, isAvailable: true),
                _buildJobsList(ordersState.activeDeliveries, isAvailable: false),
              ],
            ),
    );
  }

  Widget _buildJobsList(List<DeliveryOrder> list, {required bool isAvailable}) {
    if (list.isEmpty) {
      return RefreshIndicator(
        color: DeliveryTheme.orangePrimary,
        onRefresh: () => ref.read(deliveryOrdersProvider.notifier).loadDeliveries(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF1F5F9),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, size: 36, color: DeliveryTheme.navyLight),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAvailable ? 'No open delivery jobs right now.' : 'You have no active deliveries in transit.',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: DeliveryTheme.navyDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pull down to refresh live dispatch queue.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    if (width < 650) {
      // Mobile / narrow view: Single-column scrollable list to prevent grid height clipping or width overflow
      return RefreshIndicator(
        color: DeliveryTheme.orangePrimary,
        onRefresh: () => ref.read(deliveryOrdersProvider.notifier).loadDeliveries(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final delivery = list[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildJobCard(delivery, isAvailable: isAvailable),
            );
          },
        ),
      );
    }

    // Tablet & Desktop: Responsive grid view with safe crossAxisCount
    final crossAxisCount = width > 1100 ? 3 : 2;

    return RefreshIndicator(
      color: DeliveryTheme.orangePrimary,
      onRefresh: () => ref.read(deliveryOrdersProvider.notifier).loadDeliveries(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 185,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final delivery = list[index];
          return _buildJobCard(delivery, isAvailable: isAvailable);
        },
      ),
    );
  }

  Widget _buildJobCard(DeliveryOrder delivery, {required bool isAvailable}) {
    final orderLabel = '#${delivery.orderNumber ?? delivery.orderId.substring(0, delivery.orderId.length > 8 ? 8 : delivery.orderId.length)}';

    return Container(
      decoration: DeliveryTheme.cardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/delivery-detail', extra: delivery.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Row: Order ID & Status Badge
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              orderLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: DeliveryTheme.navyDark,
                              ),
                            ),
                          ),
                        ),
                        if (delivery.orderStatus == 'READY_FOR_PICKUP') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'READY',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  DeliveryTheme.statusBadge(isAvailable ? 'AVAILABLE' : delivery.status.name),
                ],
              ),
              const SizedBox(height: 10),

              // Route Line (Pickup -> Drop-off Timeline)
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DeliveryTheme.orangePrimary,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 16,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.farmer?.farmName ?? 'Swarna Bharat Organics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: DeliveryTheme.navyDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          delivery.deliveryAddress?.street ?? 'Delivery Address',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 14, color: Color(0xFFF1F5F9)),

              // Footer Row: Payout & Navigation Launch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '₹${(delivery.deliveryFee ?? 50.0).toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(delivery.distance ?? 3.5).toStringAsFixed(1)} km',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: DeliveryTheme.orangeGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Route',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
