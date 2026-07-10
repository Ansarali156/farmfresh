import 'package:flutter/material.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildFarmerOrderItem('Order #1024', 'John Doe', '2 kg Tomatoes, 1 bundle Spinach', '$6.20', 'Pending Dispatch', Colors.orange),
          _buildFarmerOrderItem('Order #1019', 'Jane Smith', '5 kg Apples', '$22.50', 'Shipped', Colors.blue),
          _buildFarmerOrderItem('Order #1008', 'Bob Johnson', '3 kg Carrots', '$9.00', 'Delivered', Colors.green),
        ],
      ),
    );
  }

  Widget _buildFarmerOrderItem(String orderId, String customerName, String items, String total, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Text('Customer: $customerName', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Items: $items', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Total Payout: $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (status == 'Pending Dispatch')
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Mark as Dispatched'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
