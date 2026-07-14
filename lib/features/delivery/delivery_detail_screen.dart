import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(deliveryOrdersProvider.notifier).loadDelivery(widget.deliveryId));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(deliveryOrdersProvider);
    final delivery = ordersState.selectedDelivery;

    ref.listen<DeliveryOrdersState>(deliveryOrdersProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFF4D6D),
          ),
        );
        ref.read(deliveryOrdersProvider.notifier).clearMessages();
      }
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            delivery != null ? 'Job Details #${delivery.orderId.substring(0, 8)}' : 'Delivery Details',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
        ),
        body: ordersState.isLoading || delivery == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusTimeline(delivery),
                    const SizedBox(height: 16),
                    _buildAddresses(delivery),
                    const SizedBox(height: 16),
                    if (delivery.items != null && delivery.items!.isNotEmpty) ...[
                      _buildItems(delivery),
                      const SizedBox(height: 16),
                    ],
                    _buildOrderSummary(delivery),
                    if (delivery.specialInstructions != null &&
                        delivery.specialInstructions!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSpecialInstructions(delivery),
                    ],
                    const SizedBox(height: 24),
                    _buildActionButtons(delivery, ordersState),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusTimeline(DeliveryOrder delivery) {
    final steps = [
      _TimelineStep('Assigned', 'Delivery partner allocated', delivery.assignedAt != null, Icons.assignment_outlined),
      _TimelineStep('Accepted', 'Job accepted by rider', delivery.acceptedAt != null, Icons.check_circle_outline),
      _TimelineStep('Picked Up', 'Order harvested & picked up', delivery.pickedUpAt != null, Icons.inventory_2_outlined),
      _TimelineStep('On the Way', 'Rider is en route to customer', delivery.status == DeliveryOrderStatus.outForDelivery, Icons.local_shipping_outlined),
      _TimelineStep('Delivered', 'Order marked completed', delivery.deliveredAt != null, Icons.flag_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Progress', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      step.icon,
                      size: 18,
                      color: step.completed ? const Color(0xFF2E7D32) : const Color(0xFFECECEC),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: step.completed ? const Color(0xFF2E7D32) : const Color(0xFFECECEC),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: step.completed ? const Color(0xFF23312B) : const Color(0xFF8D99AE),
                          ),
                        ),
                        Text(
                          step.subtitle,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddresses(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Addresses', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          if (delivery.pickupAddress != null || delivery.farmer != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: Color(0xFF2E7D32), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PICKUP FROM FARM', style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF8D99AE), fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(delivery.farmer?.name ?? 'Farmer',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B))),
                      Text(delivery.pickupAddress?.fullAddress ?? 'Farm address',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w500)),
                      if (delivery.farmer?.phone.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text('Phone: ${delivery.farmer!.phone}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ],
          if (delivery.deliveryAddress != null || delivery.customer != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_outlined, color: Color(0xFF219EBC), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DROP-OFF CUSTOMER ADDRESS', style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF8D99AE), fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(delivery.customer?.name ?? 'Customer',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B))),
                      Text(delivery.deliveryAddress?.fullAddress ?? 'Customer address',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w500)),
                      if (delivery.customer?.phone.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text('Phone: ${delivery.customer!.phone}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildItems(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items (${delivery.items!.length})',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          ...delivery.items!.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity}x ${item.name}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
                    ),
                    Text('₹${item.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF23312B))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          if (delivery.orderSummary != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72), fontWeight: FontWeight.w600)),
                Text('₹${delivery.orderSummary!.subtotal.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF23312B))),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Payout Fee', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              Text('₹${(delivery.deliveryFee ?? 0).toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF3F3F3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF23312B))),
              Text(
                '₹${(delivery.orderSummary?.total ?? delivery.deliveryFee ?? 0).toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF23312B)),
              ),
            ],
          ),
          if (delivery.rating != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Customer Rating: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), fontWeight: FontWeight.w600)),
                ...List.generate(5, (index) => Icon(
                      index < (delivery.rating ?? 0) ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB703),
                      size: 14,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions(DeliveryOrder delivery) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFFB703), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Special Instructions',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B))),
                const SizedBox(height: 4),
                Text(delivery.specialInstructions!, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DeliveryOrder delivery, DeliveryOrdersState ordersState) {
    final buttons = <Widget>[];

    switch (delivery.status) {
      case DeliveryOrderStatus.accepted:
        buttons.add(_buildActionButton(
          'Pick Up from Farmer',
          Icons.inventory_2_outlined,
          const Color(0xFF2E7D32),
          ordersState.isPerformingAction,
          () => ref.read(deliveryOrdersProvider.notifier).markPickedUp(delivery.id),
        ));
        break;
      case DeliveryOrderStatus.pickedUp:
        buttons.add(_buildActionButton(
          'Start Delivery to Client',
          Icons.local_shipping_outlined,
          const Color(0xFFE28C43),
          ordersState.isPerformingAction,
          () => ref.read(deliveryOrdersProvider.notifier).startDelivery(delivery.id),
        ));
        break;
      case DeliveryOrderStatus.outForDelivery:
        buttons.add(_buildActionButton(
          'Verify OTP & Complete Delivery',
          Icons.lock_open_outlined,
          const Color(0xFF2E7D32),
          ordersState.isPerformingAction,
          () => _showOtpDialog(delivery.id),
        ));
        break;
      default:
        break;
    }

    if (delivery.status == DeliveryOrderStatus.outForDelivery) {
      buttons.add(const SizedBox(height: 12));
      buttons.add(
        GestureDetector(
          onTap: () => context.push('/delivery-navigation', extra: delivery),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF219EBC)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, color: Color(0xFF219EBC), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Open Active Navigation Map',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF219EBC), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(children: buttons);
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isLoading, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showOtpDialog(String deliveryId) {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify Delivery OTP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ask the customer for their 6-digit OTP code:', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: GoogleFonts.outfit(fontSize: 24, letterSpacing: 8, color: const Color(0xFF8D99AE)),
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)))),
          ElevatedButton(
            onPressed: () async {
              final otp = _otpController.text.trim();
              if (otp.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid 6-digit OTP code'), backgroundColor: Color(0xFFFFB703)),
                );
                return;
              }
              Navigator.pop(context);
              final success = await ref.read(deliveryOrdersProvider.notifier).verifyOtp(deliveryId, otp);
              if (success && mounted) {
                await ref.read(deliveryOrdersProvider.notifier).completeDelivery(deliveryId);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: Text('Verify & Complete', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool completed;
  final IconData icon;

  _TimelineStep(this.title, this.subtitle, this.completed, this.icon);
}
