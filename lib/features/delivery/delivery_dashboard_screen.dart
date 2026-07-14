import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    Future.microtask(() {
      ref.read(deliveryDashboardProvider.notifier).loadDashboard();
      ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
      ref.read(deliveryProfileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(deliveryDashboardProvider);
    final ordersState = ref.watch(deliveryOrdersProvider);
    final profileState = ref.watch(deliveryProfileProvider);

    final allActive = [...ordersState.pendingDeliveries, ...ordersState.activeDeliveries];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Logistics & Delivery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(
                profileState.profile.isAvailable ? 'Online' : 'Offline',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Switch(
                value: profileState.profile.isAvailable,
                activeColor: Colors.lightGreenAccent,
                inactiveThumbColor: Colors.grey[300],
                inactiveTrackColor: Colors.grey[700],
                onChanged: (val) async {
                  await ref.read(deliveryProfileProvider.notifier).toggleAvailability();
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/delivery-notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(deliveryDashboardProvider.notifier).loadDashboard();
          await ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
          await ref.read(deliveryProfileProvider.notifier).loadProfile();
        },
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(dashboardState),
                    const SizedBox(height: 24),
                    _buildActiveDeliveries(ordersState, allActive),
                    const SizedBox(height: 24),
                    _buildEarningsSummary(dashboardState),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsGrid(DeliveryDashboardState state) {
    final stats = state.stats;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 6 : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Today\'s Earnings', '₹${stats.todayEarnings.toStringAsFixed(0)}', Icons.payments, Colors.green),
        _buildStatCard('Weekly Earnings', '₹${stats.weeklyEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.blue),
        _buildStatCard('Completed Today', '${stats.completedToday}', Icons.done_all, Colors.teal),
        _buildStatCard('Active Tasks', '${stats.activeDeliveries}', Icons.navigation, Colors.orange),
        _buildStatCard('Pending Jobs', '${state.dashboard.unreadNotifications}', Icons.pending_actions, Colors.amber),
        _buildStatCard('Rating', stats.averageRating.toStringAsFixed(1), Icons.star, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveries(DeliveryOrdersState ordersState, List<DeliveryOrder> allActive) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active / Available Deliveries',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${allActive.length} Jobs',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (ordersState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (allActive.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No active or pending deliveries found.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allActive.length > 5 ? 5 : allActive.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final delivery = allActive[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(delivery.status).withOpacity(0.1),
                      child: Icon(_getStatusIcon(delivery.status), color: _getStatusColor(delivery.status)),
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (delivery.orderStatus == 'READY_FOR_PICKUP') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'READY',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      delivery.deliveryAddress?.street ?? 'Unknown Destination',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/delivery-detail', extra: delivery.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(DeliveryDashboardState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            if (state.dashboard.recentEarnings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No earnings data logged yet.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...state.dashboard.recentEarnings.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.period, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                        '₹${e.amount.toStringAsFixed(2)} (${e.deliveries} orders)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Colors.orange;
      case DeliveryOrderStatus.accepted:
        return Colors.blue;
      case DeliveryOrderStatus.headingToPickup:
        return Colors.cyan;
      case DeliveryOrderStatus.pickedUp:
        return Colors.teal;
      case DeliveryOrderStatus.outForDelivery:
        return Colors.purple;
      case DeliveryOrderStatus.delivered:
        return Colors.green;
      case DeliveryOrderStatus.cancelled:
        return Colors.red;
      case DeliveryOrderStatus.rejected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return Icons.pending;
      case DeliveryOrderStatus.accepted:
        return Icons.assignment_turned_in;
      case DeliveryOrderStatus.headingToPickup:
        return Icons.directions_bike;
      case DeliveryOrderStatus.pickedUp:
        return Icons.shopping_bag;
      case DeliveryOrderStatus.outForDelivery:
        return Icons.local_shipping;
      case DeliveryOrderStatus.delivered:
        return Icons.check_circle;
      case DeliveryOrderStatus.cancelled:
        return Icons.cancel;
      case DeliveryOrderStatus.rejected:
        return Icons.close;
    }
  }
}
