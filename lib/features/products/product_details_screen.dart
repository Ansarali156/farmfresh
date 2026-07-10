import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.green[50],
              child: const Icon(Icons.spa, size: 100, color: Colors.green),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text(
                        'Organic Red Tomatoes',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$2.50 / kg',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text('4.8 (120 reviews)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 16),
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text('Santorini Farms'),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fresh organic red tomatoes grown locally without artificial chemicals or pesticides. Hand-picked straight from Santorini Farms fields to ensure maximum freshness and taste.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Cart!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
                    ),
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
