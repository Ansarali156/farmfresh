import 'package:flutter/material.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Farmer Partner!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here is your farm performance overview today.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard('Total Earnings', '$1,240.50', Icons.attach_money, Colors.green),
                _buildStatCard('Active Products', '14 Items', Icons.agriculture, Colors.orange),
                _buildStatCard('Pending Orders', '5 Orders', Icons.pending_actions, Colors.blue),
                _buildStatCard('Out of Stock', '2 Items', Icons.warning_amber_rounded, Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent Orders section
            const Text(
              'Recent Order Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildNotificationItem('Order #1024 - 2kg Organic Tomatoes', 'Pending Delivery', '10 mins ago'),
            _buildNotificationItem('Order #1021 - 5kg Fresh Potatoes', 'Completed', '2 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String status, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.shopping_bag, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Status: $status | $time'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
