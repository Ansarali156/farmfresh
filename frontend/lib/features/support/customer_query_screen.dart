import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/customer_query_provider.dart';
import '../../providers/order_provider.dart';
import '../../core/utils/app_snackbar.dart';

class CustomerQueryScreen extends ConsumerStatefulWidget {
  final String? initialOrderId;

  const CustomerQueryScreen({super.key, this.initialOrderId});

  @override
  ConsumerState<CustomerQueryScreen> createState() => _CustomerQueryScreenState();
}

class _CustomerQueryScreenState extends ConsumerState<CustomerQueryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Order Issue';
  String? _selectedOrderId;

  final List<String> _categories = [
    'Order Issue',
    'Delivery Issue',
    'Product Quality',
    'Payment & Refund',
    'Farmer & Harvest Inquiry',
    'General Support',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialOrderId != null) {
      _selectedOrderId = widget.initialOrderId;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(customerQueryProvider.notifier).submitQuery(
      subject: _subjectController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      orderId: _selectedOrderId,
    );

    if (mounted && success) {
      showAppSnackBar(
        context,
        'Support ticket created successfully!',
        type: SnackBarType.success,
      );
      _subjectController.clear();
      _descriptionController.clear();
      _tabController.animateTo(1); // Switch to My Queries tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryState = ref.watch(customerQueryProvider);
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x0A2E5C45),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF23312B)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & Customer Support',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23312B),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: const Color(0xFF647C72),
          indicatorColor: const Color(0xFF2E7D32),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Submit Query'),
            Tab(text: 'My Support Tickets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Submit Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent_rounded, color: Color(0xFF2E7D32), size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Assistance?',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFF1B2E25),
                                ),
                              ),
                              Text(
                                'Submit your query below and our FarmFresh support team will respond promptly.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF526059),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Dropdown
                  Text(
                    'Query Category',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat, style: GoogleFonts.plusJakartaSans(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subject Input
                  Text(
                    'Subject',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Question about my delivery status',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a subject' : null,
                  ),
                  const SizedBox(height: 16),

                  // Optional Order ID Dropdown
                  if (orderState.currentOrders.isNotEmpty || orderState.historyOrders.isNotEmpty) ...[
                    Text(
                      'Related Order (Optional)',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedOrderId,
                      decoration: InputDecoration(
                        hintText: 'Select an order',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                      ),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('None / General Inquiry')),
                        ...[...orderState.currentOrders, ...orderState.historyOrders].map((ord) {
                          return DropdownMenuItem(
                            value: ord.id,
                            child: Text('Order #${ord.orderNumber.isNotEmpty ? ord.orderNumber : ord.id.substring(0, 8)}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                          );
                        }),
                      ],
                      onChanged: (val) => setState(() => _selectedOrderId = val),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description Input
                  Text(
                    'Description / Details',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Provide complete details regarding your query...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECE8))),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please describe your query' : null,
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: queryState.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: queryState.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Submit Query Ticket',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab 2: My Tickets List
          queryState.queries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 60, color: Color(0xFFB0BEC5)),
                      const SizedBox(height: 12),
                      Text('No support queries submitted yet.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: queryState.queries.length,
                  itemBuilder: (context, index) {
                    final item = queryState.queries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.id,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                  ),
                                ),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.subject,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1B2E25)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF526059)),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Category: ${item.category}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(item.createdAt),
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9E9E9E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'RESOLVED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'RESOLVED';
        break;
      case 'IN_PROGRESS':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'IN PROGRESS';
        break;
      default:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        label = 'OPEN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
