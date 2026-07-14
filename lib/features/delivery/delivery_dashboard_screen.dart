import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryDashboardScreen extends ConsumerStatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  ConsumerState<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends ConsumerState<DeliveryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryDashboardProvider.notifier).loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(deliveryDashboardProvider);
    final ordersState = ref.watch(deliveryOrdersProvider);
    final profileState = ref.watch(deliveryProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://api.dicebear.com/7.x/adventurer/svg?seed=RiderAlex',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Partner',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF23312B)),
                ),
                Text(
                  'Rider Dashboard',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              Text(
                profileState.profile.isAvailable ? 'Online' : 'Offline',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: profileState.profile.isAvailable,
                activeColor: Colors.lightGreenAccent,
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[700],
                onChanged: (val) async {
                  await ref.read(deliveryProfileProvider.notifier).toggleAvailability();
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF23312B)),
                onPressed: () => context.push('/delivery-notifications'),
              ),
              if (dashboardState.dashboard.unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4D6D),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${dashboardState.dashboard.unreadNotifications}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2E7D32),
        onRefresh: () async {
          await ref.read(deliveryDashboardProvider.notifier).loadDashboard();
          await ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
        },
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : dashboardState.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF4D6D)),
                          const SizedBox(height: 12),
                          Text(
                            dashboardState.errorMessage!,
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF4D6D)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(deliveryDashboardProvider.notifier).loadDashboard(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(dashboardState),
                        const SizedBox(height: 16),
                        _buildEarningsSummary(dashboardState),
                        const SizedBox(height: 16),
                        _buildActiveDeliveries(ordersState),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatsGrid(DeliveryDashboardState state) {
    final stats = state.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Today\'s Payout', '₹${stats.todayEarnings.toStringAsFixed(2)}', Icons.payments_outlined, const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
        _buildStatCard('Weekly Payout', '₹${stats.weeklyEarnings.toStringAsFixed(2)}', Icons.date_range_outlined, const Color(0xFF219EBC), const Color(0xFFF0F9FB)),
        _buildStatCard('Completed Jobs', '${stats.completedToday}', Icons.check_circle_outline, const Color(0xFF8338EC), const Color(0xFFF5EFFF)),
        _buildStatCard('Active Jobs', '${stats.activeDeliveries}', Icons.local_shipping_outlined, const Color(0xFFE28C43), const Color(0xFFFFF1E6)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF23312B)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary(DeliveryDashboardState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings Summary', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
          const Divider(height: 20, color: Color(0xFFF3F3F3)),
          if (state.dashboard.recentEarnings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No earnings data yet', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12)),
            )
          else
            ...state.dashboard.recentEarnings.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.period, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF23312B))),
                      Text('₹${e.amount.toStringAsFixed(2)} (${e.deliveries} jobs)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF2E7D32))),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveries(DeliveryOrdersState ordersState) {
    final allActive = [...ordersState.pendingDeliveries, ...ordersState.activeDeliveries];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Deliveries', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${allActive.length} Active',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          if (ordersState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              ),
            )
          else if (allActive.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 36, color: Color(0xFF647C72)),
                    const SizedBox(height: 8),
                    Text('No active delivery requests at this moment.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11)),
                  ],
                ),
              ),
            )
          else
            ...allActive.take(5).map((delivery) => _buildDeliveryTile(delivery)),
        ],
      ),
    );
  }

  Widget _buildDeliveryTile(DeliveryOrder delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F2EF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(delivery.status).withOpacity(0.1),
          radius: 18,
          child: Icon(_getStatusIcon(delivery.status), color: _getStatusColor(delivery.status), size: 16),
        ),
        title: Text(
          'Order #${delivery.orderId.substring(0, 8)}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
        ),
        subtitle: Text(
          _getStatusText(delivery.status),
          style: GoogleFonts.plusJakartaSans(color: _getStatusColor(delivery.status), fontSize: 10, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
        onTap: () => context.push('/delivery-detail', extra: delivery.id),
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

  IconData _getStatusIcon(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Icons.pending_actions_outlined;
      case DeliveryOrderStatus.accepted:
        return Icons.check_circle_outline;
      case DeliveryOrderStatus.pickedUp:
        return Icons.inventory_2_outlined;
      case DeliveryOrderStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case DeliveryOrderStatus.delivered:
        return Icons.check_circle;
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusText(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return 'Awaiting acceptance';
      case DeliveryOrderStatus.accepted:
        return 'Ready to pick up';
      case DeliveryOrderStatus.pickedUp:
        return 'Picked up from farmer';
      case DeliveryOrderStatus.outForDelivery:
        return 'On the way to customer';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.rejected:
        return 'Rejected';
    }
  }
}
