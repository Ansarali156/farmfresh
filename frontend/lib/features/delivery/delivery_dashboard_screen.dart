import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../providers/auth_provider.dart';

// Theme Constants
const Color _bg = Color(0xFFF8FAFC);
const Color _primary = Color(0xFF2563EB);
const Color _success = Color(0xFF22C55E);
const Color _warning = Color(0xFFF59E0B);
const Color _danger = Color(0xFFEF4444);
const Color _cardBg = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF111827);
const Color _textSecondary = Color(0xFF6B7280);
const Color _border = Color(0xFFE5E7EB);

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
    final authState = ref.watch(authProvider);

    final allActive = [...ordersState.pendingDeliveries, ...ordersState.activeDeliveries];
    final activeRouteJob = allActive.isNotEmpty ? allActive.first : null;

    final userName = authState.user?.name ?? 'Rahul';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: () async {
            await ref.read(deliveryDashboardProvider.notifier).loadDashboard();
            await ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
            await ref.read(deliveryProfileProvider.notifier).loadProfile();
          },
          child: dashboardState.isLoading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(userName, profileState),
                      const SizedBox(height: 24),
                      _buildDashboardSummary(dashboardState),
                      const SizedBox(height: 24),
                      _buildActiveDeliveryCard(activeRouteJob),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildPerformanceStats(dashboardState),
                      const SizedBox(height: 24),
                      _buildDeliveryHistory(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, DeliveryProfileState profileState) {
    final bool isOnline = profileState.profile.isAvailable;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👋 Good Morning',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _textSecondary),
                ),
                Text(
                  userName.split(' ').first,
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: _textPrimary),
                ),
                Text(
                  'Delivery Partner',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: _primary),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: _textPrimary, size: 24),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: _textPrimary, size: 24),
                  onPressed: () => context.push('/delivery-notifications'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: _primary, size: 20),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            await ref.read(deliveryProfileProvider.notifier).toggleAvailability();
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isOnline ? _success.withOpacity(0.1) : _textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isOnline ? _success.withOpacity(0.3) : _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? _success : _textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'ONLINE' : 'OFFLINE',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isOnline ? _success : _textSecondary, letterSpacing: 0.5),
                        ),
                        Text(
                          isOnline ? 'Working since 09:00 AM' : 'Go online to receive orders',
                          style: GoogleFonts.inter(fontSize: 12, color: _textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Today\'s Target',
                      style: GoogleFonts.inter(fontSize: 12, color: _textSecondary),
                    ),
                    Text(
                      '15 Deliveries',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardSummary(DeliveryDashboardState state) {
    final stats = state.stats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _AnimatedStatCard('Today\'s Orders', '${stats.completedToday + stats.activeDeliveries}', '3 waiting', Icons.inventory_2_outlined, _primary)),
            const SizedBox(width: 16),
            Expanded(child: _AnimatedStatCard('Today\'s Earnings', '₹${stats.todayEarnings.toStringAsFixed(0)}', '+18%', Icons.account_balance_wallet_outlined, _success)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _AnimatedStatCard('Completed', '${stats.completedToday}', 'Excellent', Icons.check_circle_outline, _success)),
            const SizedBox(width: 16),
            Expanded(child: _AnimatedStatCard('Pending', '${state.dashboard.unreadNotifications}', 'Need attention', Icons.schedule, _warning)),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveDeliveryCard(DeliveryOrder? delivery) {
    if (delivery == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _primary.withOpacity(0.05), shape: BoxShape.circle),
              child: const Icon(Icons.map_outlined, color: _primary, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'No Active Deliveries',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll automatically receive nearby delivery requests.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: _textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(deliveryDashboardProvider.notifier).loadDashboard();
                ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Delivery',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${delivery.deliveryFee?.toStringAsFixed(0) ?? '50'}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _primary, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(Icons.storefront_outlined, delivery.farmer?.farmName ?? 'Pickup Location', 'Pickup', isLast: false, color: _primary),
          _buildTimelineItem(Icons.location_on_outlined, delivery.deliveryAddress?.street ?? 'Drop Location', 'Dropoff', isLast: true, color: _danger),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: _border,
                      child: Icon(Icons.person, size: 20, color: _textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer', style: GoogleFonts.inter(fontSize: 12, color: _textSecondary)),
                        Text('Rahul Kumar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Distance', style: GoogleFonts.inter(fontSize: 12, color: _textSecondary)),
                    Text('3.2 km • 15m', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _success,
                    side: const BorderSide(color: _success),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/delivery-detail', extra: delivery.id),
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String subtitle, {required bool isLast, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: _border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: _textSecondary, fontSize: 12),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(Icons.map_outlined, 'Navigate', const Color(0xFFE0E7FF), _primary),
            _buildActionItem(Icons.route_outlined, 'Map', const Color(0xFFFEF3C7), _warning),
            _buildActionItem(Icons.history, 'History', const Color(0xFFF3F4F6), _textSecondary),
            _buildActionItem(Icons.headset_mic_outlined, 'Support', const Color(0xFFDCFCE7), _success),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(DeliveryDashboardState state) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Performance',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildPerformanceCard('Earnings', '₹${stats.todayEarnings.toStringAsFixed(0)}', Icons.payments_outlined, _success),
              const SizedBox(width: 16),
              _buildPerformanceCard('Orders', '${stats.completedToday}', Icons.shopping_bag_outlined, _primary),
              const SizedBox(width: 16),
              _buildPerformanceCard('Distance', '12 km', Icons.directions_bike_outlined, _warning),
              const SizedBox(width: 16),
              _buildPerformanceCard('Rating', stats.averageRating.toStringAsFixed(1), Icons.star_border, _warning),
              const SizedBox(width: 16),
              _buildPerformanceCard('Completion', '98%', Icons.pie_chart_outline, _success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDeliveryHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Deliveries',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.check_circle, color: _success, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul Kumar',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sector ${12 + index}, Main Road',
                          style: GoogleFonts.inter(fontSize: 12, color: _textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${50 + (index * 15)}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${2 + index}h ago',
                        style: GoogleFonts.inter(fontSize: 12, color: _textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AnimatedStatCard(this.title, this.value, this.subtitle, this.icon, this.color);

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.05),
                  blurRadius: _isPressed ? 5 : 15,
                  offset: Offset(0, _isPressed ? 2 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.value,
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
