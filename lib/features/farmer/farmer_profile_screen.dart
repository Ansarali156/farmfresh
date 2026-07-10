import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person_pin, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Green Valley Farms',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Partner ID: #F-98732',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance, color: Colors.green),
                    title: const Text('Bank Details (Payouts)'),
                    trailing: const Icon(Icons.chevron_right),
                    onPressed: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.green),
                    title: const Text('Farm Location & Address'),
                    trailing: const Icon(Icons.chevron_right),
                    onPressed: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: Colors.green),
                    title: const Text('Contact Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Switch back to customer view
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/login'); // Return to login to switch roles
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch Role / Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
