import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../core/theme/delivery_theme.dart';

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

    final DeliveryOrder? activeRouteJob = allActive.isNotEmpty
        ? allActive.firstWhere(
            (o) => o.status != DeliveryOrderStatus.pending && o.status != DeliveryOrderStatus.delivered && o.status != DeliveryOrderStatus.cancelled && o.status != DeliveryOrderStatus.rejected,
            orElse: () => allActive.first,
          )
        : null;

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: DeliveryTheme.orangeGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Logistics Hub',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Express Fleet',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: DeliveryTheme.navyDark,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
        centerTitle: false,
        actions: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: profileState.profile.isAvailable
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : const Color(0xFF64748B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: profileState.profile.isAvailable ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: profileState.profile.isAvailable ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                        boxShadow: profileState.profile.isAvailable
                            ? const [
                                BoxShadow(
                                  color: Color(0xFF10B981),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profileState.profile.isAvailable ? 'ONLINE' : 'OFFLINE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: profileState.profile.isAvailable ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Switch(
                value: profileState.profile.isAvailable,
                activeColor: DeliveryTheme.orangePrimary,
                activeTrackColor: const Color(0xFFFED7AA),
                inactiveThumbColor: const Color(0xFF94A3B8),
                inactiveTrackColor: const Color(0xFF334155),
                onChanged: (val) async {
                  await ref.read(deliveryProfileProvider.notifier).toggleAvailability();
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.push('/delivery-notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2E7D32),
        onRefresh: () async {
          await ref.read(deliveryDashboardProvider.notifier).loadDashboard();
          await ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
          await ref.read(deliveryProfileProvider.notifier).loadProfile();
        },
        child: dashboardState.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats / KPIs
                    _EntranceAnimation(
                      delayMs: 0,
                      child: _buildStatsGrid(dashboardState, context),
                    ),
                    const SizedBox(height: 24),

                    // Active route maps details
                    if (activeRouteJob != null) ...[
                      _EntranceAnimation(
                        delayMs: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Route Tracker',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DeliveryTheme.navyDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRouteMapCard(activeRouteJob, context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Active / Available Deliveries
                    _EntranceAnimation(
                      delayMs: 200,
                      child: _buildActiveDeliveries(ordersState, allActive, context),
                    ),
                    const SizedBox(height: 24),

                    // Earnings summary
                    _EntranceAnimation(
                      delayMs: 300,
                      child: _buildEarningsSummary(dashboardState, context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double borderRadius = 20.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE4EAE0);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : const Color(0x0A2E5C45);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _buildStatsGrid(DeliveryDashboardState state, BuildContext context) {
    final stats = state.stats;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100 ? 6 : (width > 600 ? 3 : 2);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _HoverScale(
          child: _buildStatCard(
            title: "Today's Payout",
            value: '₹${stats.todayEarnings.toStringAsFixed(0)}',
            icon: Icons.payments,
            gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B4332)],
            primaryColor: const Color(0xFF2E7D32),
            context: context,
          ),
        ),
        _HoverScale(
          child: _buildStatCard(
            title: 'Weekly Payout',
            value: '₹${stats.weeklyEarnings.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet,
            gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
            primaryColor: const Color(0xFF1565C0),
            context: context,
          ),
        ),
        _HoverScale(
          child: _buildStatCard(
            title: 'Completed Jobs',
            value: '${stats.completedToday}',
            icon: Icons.done_all,
            gradientColors: const [Color(0xFF00897B), Color(0xFF004D40)],
            primaryColor: const Color(0xFF00897B),
            context: context,
          ),
        ),
        _HoverScale(
          child: _buildStatCard(
            title: 'Active Runs',
            value: '${stats.activeDeliveries}',
            icon: Icons.navigation,
            gradientColors: const [Color(0xFFE65100), Color(0xFFFF8F00)],
            primaryColor: const Color(0xFFE65100),
            context: context,
          ),
        ),
        _HoverScale(
          child: _buildStatCard(
            title: 'Unassigned Jobs',
            value: '${state.dashboard.unreadNotifications}',
            icon: Icons.pending_actions,
            gradientColors: const [Color(0xFFD84315), Color(0xFFBF360C)],
            primaryColor: const Color(0xFFD84315),
            context: context,
          ),
        ),
        _HoverScale(
          child: _buildStatCard(
            title: 'Partner Rating',
            value: stats.averageRating.toStringAsFixed(1),
            icon: Icons.star,
            gradientColors: const [Color(0xFF8E24AA), Color(0xFF4A148C)],
            primaryColor: const Color(0xFF8E24AA),
            context: context,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required Color primaryColor,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassCard(
      context: context,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF23312B),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : const Color(0xFF647C72),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveries(DeliveryOrdersState ordersState, List<DeliveryOrder> allActive, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Tasks',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF23312B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B4332)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${allActive.length} Jobs Active',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ordersState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          )
        else if (allActive.isEmpty)
          _buildGlassCard(
            context: context,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'No active or pending deliveries found.',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allActive.length > 5 ? 5 : allActive.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _HoverScale(
                child: _buildDeliveryItemCard(allActive[index], context),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDeliveryItemCard(DeliveryOrder delivery, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(delivery.status);

    // Stepper indicators
    int currentStep = 0;
    switch (delivery.status) {
      case DeliveryOrderStatus.pending:
      case DeliveryOrderStatus.accepted:
        currentStep = 0;
        break;
      case DeliveryOrderStatus.headingToPickup:
        currentStep = 1;
        break;
      case DeliveryOrderStatus.pickedUp:
        currentStep = 2;
        break;
      case DeliveryOrderStatus.outForDelivery:
        currentStep = 3;
        break;
      case DeliveryOrderStatus.delivered:
        currentStep = 4;
        break;
      default:
        break;
    }

    return _buildGlassCard(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(_getStatusIcon(delivery.status), color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF23312B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (delivery.orderStatus == 'READY_FOR_PICKUP') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF1B4332)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'READY',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${delivery.deliveryFee?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper Indicator Progress Row
          Row(
            children: [
              _buildStepIcon(Icons.assignment, currentStep >= 0, isDark),
              _buildStepConnector(currentStep >= 1, isDark),
              _buildStepIcon(Icons.agriculture, currentStep >= 1, isDark),
              _buildStepConnector(currentStep >= 2, isDark),
              _buildStepIcon(Icons.local_shipping, currentStep >= 2, isDark),
              _buildStepConnector(currentStep >= 3, isDark),
              _buildStepIcon(Icons.check_circle, currentStep >= 3, isDark),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF647C72)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'From: ${delivery.farmer?.farmName ?? 'Farmer'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : const Color(0xFF647C72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF647C72)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'To: ${delivery.deliveryAddress?.street ?? 'Customer'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : const Color(0xFF647C72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => context.push('/delivery-detail', extra: delivery.id),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(
                  'Manage Job',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, bool active, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF2E7D32)
            : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE4EAE0)),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: active ? Colors.white : Colors.grey,
        size: 14,
      ),
    );
  }

  Widget _buildStepConnector(bool active, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        color: active
            ? const Color(0xFF2E7D32)
            : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE4EAE0)),
      ),
    );
  }

  Widget _buildRouteMapCard(DeliveryOrder delivery, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double progress = 0.05;
    String stepLabel = 'Assigned';
    switch (delivery.status) {
      case DeliveryOrderStatus.pending:
      case DeliveryOrderStatus.accepted:
        progress = 0.15;
        stepLabel = 'Accepted';
        break;
      case DeliveryOrderStatus.headingToPickup:
        progress = 0.4;
        stepLabel = 'Heading to Pickup';
        break;
      case DeliveryOrderStatus.pickedUp:
        progress = 0.65;
        stepLabel = 'Picked Up Crop';
        break;
      case DeliveryOrderStatus.outForDelivery:
        progress = 0.85;
        stepLabel = 'Out for Delivery';
        break;
      case DeliveryOrderStatus.delivered:
        progress = 1.0;
        stepLabel = 'Delivered';
        break;
      default:
        break;
    }

    return _buildGlassCard(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE ROUTE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF23312B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stepLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Draw map layout
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final vehicleOffset = _getVehicleOffset(Size(width, 60), progress);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Curved Line
                  SizedBox(
                    height: 60,
                    width: width,
                    child: CustomPaint(
                      painter: _RouteMapPainter(
                        progress: progress,
                        activeColor: const Color(0xFF2E7D32),
                        inactiveColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFFE4EAE0),
                      ),
                    ),
                  ),

                  // Start Pin (Farmer)
                  Positioned(
                    left: 0,
                    top: 15,
                    child: Tooltip(
                      message: delivery.farmer?.farmName ?? 'Pickup Farm',
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // End Pin (Customer)
                  Positioned(
                    right: 0,
                    top: 15,
                    child: Tooltip(
                      message: delivery.deliveryAddress?.street ?? 'Delivery address',
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF0F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home, color: Color(0xFFFF4D6D),
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // Vehicle along path
                  Positioned(
                    left: vehicleOffset.dx - 16,
                    top: vehicleOffset.dy - 16,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bike,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF647C72)),
                  const SizedBox(width: 4),
                  Text(
                    delivery.estimatedDeliveryTime ?? '30 mins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : const Color(0xFF647C72),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF647C72)),
                  const SizedBox(width: 4),
                  Text(
                    '${delivery.distance?.toStringAsFixed(1) ?? '2.5'} km away',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : const Color(0xFF647C72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Offset _getVehicleOffset(Size size, double progress) {
    final path = Path();
    path.moveTo(10, 30);
    path.cubicTo(
      (size.width - 20) * 0.25 + 10, 10,
      (size.width - 20) * 0.75 + 10, 50,
      size.width - 10, 30,
    );
    try {
      final metrics = path.computeMetrics();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final length = metric.length;
        final tangent = metric.getTangentForOffset(length * progress);
        if (tangent != null) {
          return tangent.position;
        }
      }
    } catch (_) {}
    return Offset(size.width / 2, 30);
  }

  Widget _buildEarningsSummary(DeliveryDashboardState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildGlassCard(
      context: context,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Earnings',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF23312B),
                ),
              ),
              const Icon(Icons.bar_chart, color: Color(0xFF2E7D32), size: 20),
            ],
          ),
          const Divider(height: 24),
          if (state.dashboard.recentEarnings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No earnings data logged yet.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Period',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : const Color(0xFF647C72),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Deliveries',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : const Color(0xFF647C72),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : const Color(0xFF647C72),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.dashboard.recentEarnings.length,
              separatorBuilder: (context, index) => const Divider(height: 12, thickness: 0.3),
              itemBuilder: (context, rowIndex) {
                final e = state.dashboard.recentEarnings[rowIndex];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.period,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF23312B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${e.deliveries} jobs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '₹${e.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
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

class _RouteMapPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _RouteMapPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(10, 30);
    path.cubicTo(
      (size.width - 20) * 0.25 + 10, 10,
      (size.width - 20) * 0.75 + 10, 50,
      size.width - 10, 30,
    );

    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final totalLength = pathMetric.length;
      final activeLength = totalLength * progress;

      // Draw inactive segment
      paintLine.color = inactiveColor;
      canvas.drawPath(path, paintLine);

      // Draw active segment
      if (activeLength > 0) {
        final activePath = pathMetric.extractPath(0, activeLength);
        paintLine.color = activeColor;
        canvas.drawPath(activePath, paintLine);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

class _EntranceAnimation extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _EntranceAnimation({required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  double _scale = 1.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _scale = 1.025;
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _scale = 1.0;
        _isHovered = false;
      }),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
