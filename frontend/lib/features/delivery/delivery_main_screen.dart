import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'delivery_dashboard_screen.dart';
import 'delivery_orders_screen.dart';
import 'delivery_earnings_screen.dart';
import 'delivery_profile_screen.dart';
import '../../core/theme/delivery_theme.dart';

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DeliveryDashboardScreen(),
    DeliveryOrdersScreen(),
    DeliveryEarningsScreen(),
    DeliveryProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DeliveryTheme.bgCanvas,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: DeliveryTheme.navyDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F0F172A),
                offset: Offset(0, -6),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.alt_route_outlined, Icons.alt_route_rounded, 'Routes'),
                _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earnings'),
                _buildNavItem(3, Icons.badge_outlined, Icons.badge_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? DeliveryTheme.orangeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x3DF97316),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
