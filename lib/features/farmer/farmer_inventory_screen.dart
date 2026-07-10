import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/farmer_provider.dart';
import '../../models/inventory_model.dart';

class FarmerInventoryScreen extends ConsumerStatefulWidget {
  const FarmerInventoryScreen({super.key});

  @override
  ConsumerState<FarmerInventoryScreen> createState() => _FarmerInventoryScreenState();
}

class _FarmerInventoryScreenState extends ConsumerState<FarmerInventoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmerInventoryProvider.notifier).loadMore();
    }
  }

  int _countLowStock(List<InventoryModel> items) {
    return items.where((i) => i.isLowStock).length;
  }

  int _countOutOfStock(List<InventoryModel> items) {
    return items.where((i) => i.isOutOfStock).length;
  }

  void _showUpdateStockDialog(InventoryModel item) {
    final controller = TextEditingController(text: item.currentStock.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${item.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Stock: ${item.currentStock.toStringAsFixed(0)} ${item.unit}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'New Quantity',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _quickActionChip('-10', () async {
                  Navigator.pop(context);
                  await ref.read(farmerInventoryProvider.notifier).removeStock(item.id, 10);
                }),
                const SizedBox(width: 8),
                _quickActionChip('+10', () async {
                  Navigator.pop(context);
                  await ref.read(farmerInventoryProvider.notifier).addStock(item.id, 10);
                }),
                const SizedBox(width: 8),
                _quickActionChip('+50', () async {
                  Navigator.pop(context);
                  await ref.read(farmerInventoryProvider.notifier).addStock(item.id, 50);
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(controller.text);
              if (qty == null) return;
              Navigator.pop(context);
              await ref.read(farmerInventoryProvider.notifier).updateStock(item.id, qty);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Set Stock'),
          ),
        ],
      ),
    );
  }

  Widget _quickActionChip(String label, VoidCallback onTap) {
    return Expanded(
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        onPressed: onTap,
        backgroundColor: Colors.green[50],
        side: BorderSide(color: Colors.green[300]!),
      ),
    );
  }

  Widget _buildStatusBadge(InventoryModel item) {
    Color bgColor;
    Color textColor;
    String text;

    if (item.isOutOfStock) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      text = 'Out of Stock';
    } else if (item.isLowStock) {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      text = 'Low Stock';
    } else {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      text = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmerInventoryProvider);

    ref.listen<FarmerInventoryState>(farmerInventoryProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
        ref.read(farmerInventoryProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null && next.actionMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(farmerInventoryProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(farmerInventoryProvider.notifier).loadInventory(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : state.items.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildSummaryRow(state.items),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.read(farmerInventoryProvider.notifier).loadInventory(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(color: Colors.green)),
                              );
                            }
                            final item = state.items[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.productName,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        _buildStatusBadge(item),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Current Stock: ${item.currentStock.toStringAsFixed(0)} ${item.unit}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Available: ${item.availableStock.toStringAsFixed(0)} ${item.unit}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showUpdateStockDialog(item),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Update Stock'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryRow(List<InventoryModel> items) {
    final total = items.length;
    final lowStock = _countLowStock(items);
    final outOfStock = _countOutOfStock(items);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      color: Colors.green[50],
      child: Row(
        children: [
          _summaryTile('Total Items', total.toString(), Colors.green),
          const SizedBox(width: 8),
          _summaryTile('Low Stock', lowStock.toString(), Colors.orange),
          const SizedBox(width: 8),
          _summaryTile('Out of Stock', outOfStock.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No Inventory Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add products to start managing your inventory.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
