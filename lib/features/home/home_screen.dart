import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmFresh Marketplace'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              context.push('/cart');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Card(
              color: Colors.green[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Save up to 50%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                          SizedBox(height: 4),
                          Text('Direct from local farms to your home', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Icon(Icons.spa, size: 48, color: Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Categories
            const Text('Popular Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryPill('Vegetables', Icons.eco, true),
                  _buildCategoryPill('Fruits', Icons.apple, false),
                  _buildCategoryPill('Dairy', Icons.egg, false),
                  _buildCategoryPill('Grains', Icons.grain, false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Products List
            const Text('Featured Fresh Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
              children: [
                _buildProductCard(context, 'Organic Tomatoes', '$2.50 / kg', 'Santorini Farms', Icons.spa),
                _buildProductCard(context, 'Fresh Spinach', '$1.20 / bundle', 'Green Valley Farms', Icons.grass),
                _buildProductCard(context, 'Red Gala Apples', '$4.50 / kg', 'Hilltop Orchards', Icons.apple),
                _buildProductCard(context, 'Farm Fresh Eggs', '$3.50 / dozen', 'Sunny Poultry', Icons.egg),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String title, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        avatar: Icon(icon, size: 16),
        selected: active,
        onSelected: (val) {},
        selectedColor: Colors.green[200],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String name, String price, String farm, IconData icon) {
    return InkWell(
      onTap: () {
        context.push('/product-details');
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(icon, size: 48, color: Colors.green),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(farm, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const Icon(Icons.add_circle, color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
