import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../core/theme/delivery_theme.dart';

class DeliveryEarningsScreen extends ConsumerStatefulWidget {
  const DeliveryEarningsScreen({super.key});

  @override
  ConsumerState<DeliveryEarningsScreen> createState() => _DeliveryEarningsScreenState();
}

class _DeliveryEarningsScreenState extends ConsumerState<DeliveryEarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryEarningsProvider.notifier).loadEarnings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryEarningsProvider);

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Fleet Wallet & Earnings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: DeliveryTheme.navyDark,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => context.push('/delivery-history'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(deliveryEarningsProvider.notifier).loadEarnings(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(state),
                    const SizedBox(height: 24),
                    const Text('Recent Wallet Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTransactionsList(state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(DeliveryEarningsState state) {
    final earnings = state.earnings;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade700,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL WALLET BALANCE',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${(earnings.totalEarnings - earnings.completedWithdrawals).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceMeta('Pending Cash', '₹${earnings.pendingWithdrawals.toStringAsFixed(0)}'),
                _buildBalanceMeta('Total Payouts', '₹${earnings.completedWithdrawals.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showPayoutDialog(earnings.totalEarnings - earnings.completedWithdrawals),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Request Payout to Bank', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTransactionsList(DeliveryEarningsState state) {
    final list = state.transactions;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('No transactions recorded yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = list[index];
        final isPayout = tx.type.toUpperCase() == 'WITHDRAWAL';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: isPayout ? Colors.red.shade50 : Colors.green.shade50,
            child: Icon(isPayout ? Icons.call_made : Icons.call_received, color: isPayout ? Colors.red : Colors.green),
          ),
          title: Text(
            isPayout ? 'Payout to Bank' : 'Delivery Earnings',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            tx.createdAt.toString().substring(0, 10),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Text(
            '${isPayout ? "-" : "+"}₹${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPayout ? Colors.red : Colors.green,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }

  void _showPayoutDialog(double balance) {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have no wallet balance to withdraw.'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payout Request'),
        content: Text(
          'Your payout of ₹${balance.toStringAsFixed(2)} will be initiated to your registered bank account inside your profile. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payout requested successfully! processing in 2-3 business days.'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
