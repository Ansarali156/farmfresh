import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildOrderItem('Order #1004', 'July 8, 2026', '2 kg Tomatoes', '\$8.20', 'In Transit', Colors.blue),
          _buildOrderItem('Order #0988', 'July 5, 2026', '1 bundle Spinach, 1 dozen Eggs', '\$6.70', 'Delivered', Colors.green),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderId, String date, String items, String price, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Date: $date', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Items: $items', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Total Paid: $price', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
