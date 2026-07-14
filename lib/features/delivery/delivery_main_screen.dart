import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import 'delivery_dashboard_screen.dart';
import 'delivery_orders_screen.dart';
import 'delivery_earnings_screen.dart';
import 'delivery_history_screen.dart';
import 'delivery_profile_screen.dart';

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
  int _currentTabIndex = 0;

  final _screens = const [
    DeliveryDashboardScreen(),
    DeliveryOrdersScreen(),
    DeliveryEarningsScreen(),
    DeliveryHistoryScreen(),
    DeliveryProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(deliveryOrdersProvider.notifier).loadDeliveries();
      ref.read(deliveryNotificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(deliveryNotificationProvider);
    final deliveryOrdersState = ref.watch(deliveryOrdersProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _currentTabIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x0F2E5C45),
                offset: Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) => setState(() => _currentTabIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: const Color(0xFF8D99AE),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined, size: 20),
                activeIcon: Icon(Icons.dashboard, size: 20),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 20),
                    if (deliveryOrdersState.pendingDeliveries.isNotEmpty)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4D6D),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${deliveryOrdersState.pendingDeliveries.length}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.local_shipping, size: 20),
                    if (deliveryOrdersState.pendingDeliveries.isNotEmpty)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4D6D),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${deliveryOrdersState.pendingDeliveries.length}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Deliveries',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                activeIcon: Icon(Icons.account_balance_wallet, size: 20),
                label: 'Earnings',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined, size: 20),
                activeIcon: Icon(Icons.history, size: 20),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4D6D),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifState.unreadCount}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.person, size: 20),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4D6D),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifState.unreadCount}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
