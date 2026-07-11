import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'farmer_dashboard_screen.dart';
import 'farmer_products_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_earnings_screen.dart';
import 'farmer_profile_screen.dart';
import '../../providers/farmer_provider.dart';

class FarmerMainScreen extends ConsumerStatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  ConsumerState<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends ConsumerState<FarmerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FarmerDashboardScreen(),
    FarmerProductsScreen(),
    FarmerOrdersScreen(),
    FarmerEarningsScreen(),
    FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(farmerNotificationProvider);
    final unreadCount = notifState.unreadCount;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Products',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.person),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
