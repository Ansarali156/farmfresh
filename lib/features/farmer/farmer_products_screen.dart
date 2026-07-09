import 'package:flutter/material.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Action to add product
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Product form coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildProductItem('Organic Red Tomatoes', '12 kg available', '$2.50 / kg', true),
          _buildProductItem('Fresh Green Spinach', '25 bundles available', '$1.20 / bundle', true),
          _buildProductItem('Sweet Baby Carrots', '0 kg available', '$3.00 / kg', false),
          _buildProductItem('Golden Honeycrisp Apples', '50 kg available', '$4.50 / kg', true),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String stock, String price, bool inStock) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: inStock ? Colors.green[100] : Colors.red[100],
          child: Icon(
            Icons.agriculture,
            color: inStock ? Colors.green : Colors.red,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock: $stock'),
            Text('Price: $price', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
