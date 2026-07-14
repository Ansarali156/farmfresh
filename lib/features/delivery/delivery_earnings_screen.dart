import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';

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
    final earningsState = ref.watch(deliveryEarningsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Earnings Log',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: earningsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () => ref.read(deliveryEarningsProvider.notifier).loadEarnings(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green Gradient Main Wallet Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F2E7D32),
                            offset: Offset(0, 8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ACCUMULATED PAYOUT',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${earningsState.earnings.totalEarnings.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Grid Row Cards
                    Row(
                      children: [
                        Expanded(child: _buildEarningCard('Today', '₹${earningsState.earnings.dailyEarnings.toStringAsFixed(2)}', const Color(0xFF2E7D32))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildEarningCard('This Week', '₹${earningsState.earnings.weeklyEarnings.toStringAsFixed(2)}', const Color(0xFF219EBC))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildEarningCard('This Month', '₹${earningsState.earnings.monthlyEarnings.toStringAsFixed(2)}', const Color(0xFF8338EC))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildEarningCard('Base Balance', '₹${earningsState.earnings.totalEarnings.toStringAsFixed(2)}', const Color(0xFFE28C43))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Rider Transaction Ledger',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF23312B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (earningsState.transactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF647C72)),
                              const SizedBox(height: 12),
                              Text(
                                'No payment records found yet.',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ...earningsState.transactions.map((t) => _buildTransactionTile(t)),
                      if (earningsState.hasMore && earningsState.transactions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: earningsState.isLoadingMore
                                ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                                : TextButton(
                                    onPressed: () => ref.read(deliveryEarningsProvider.notifier).loadMoreTransactions(),
                                    child: Text(
                                      'Load More Transactions',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEarningCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF647C72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic transaction) {
    String dateStr = '';
    try {
      dateStr = DateFormat('dd/MM/yyyy').format(transaction.createdAt);
    } catch (_) {
      dateStr = '';
    }

    final isCredit = transaction.type == 'CREDIT' || transaction.type == 'earning';
    final accentColor = isCredit ? const Color(0xFF2E7D32) : const Color(0xFFFF4D6D);
    final iconBg = isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF0F3);
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: iconBg,
          radius: 18,
          child: Icon(
            icon,
            color: accentColor,
            size: 16,
          ),
        ),
        title: Text(
          transaction.description.toString(),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
        ),
        subtitle: Text(
          dateStr,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}
