import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/delivery_tracking_service.dart';
import '../../core/theme/delivery_theme.dart';
import '../../core/widgets/map_zoom_controls.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  final _otpController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(deliveryOrdersProvider.notifier).loadDelivery(widget.deliveryId);
      _autoStartTracking();
    });
  }

  void _autoStartTracking() {
    final delivery = ref.read(deliveryOrdersProvider).selectedDelivery;
    if (delivery == null) return;

    final isTrackingStatus =
        delivery.status == DeliveryOrderStatus.headingToPickup ||
        delivery.status == DeliveryOrderStatus.outForDelivery;

    if (isTrackingStatus) {
      ref.read(deliveryTrackingServiceProvider).startTracking(delivery.id);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryOrdersProvider);
    final delivery = state.selectedDelivery;

    if (state.isLoading || delivery == null) {
      return Scaffold(
        backgroundColor: DeliveryTheme.bgCanvas,
        appBar: AppBar(
          title: Text('Loading Route...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: DeliveryTheme.navyDark,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: DeliveryTheme.orangePrimary)),
      );
    }

    return Scaffold(
      backgroundColor: DeliveryTheme.bgCanvas,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${delivery.orderNumber ?? delivery.orderId.substring(0, 8)}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              'Logistics Dispatch Details',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
        backgroundColor: DeliveryTheme.navyDark,
        elevation: 4,
        shadowColor: const Color(0x3D0F172A),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DeliveryTheme.statusBadge(delivery.status.name),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteMapCard(delivery),
                const SizedBox(height: 16),
                _buildLocationsTimeline(delivery),
                const SizedBox(height: 16),
                _buildFarmerCard(delivery),
                const SizedBox(height: 16),
                _buildCustomerCard(delivery),
                const SizedBox(height: 16),
                _buildOrderItemsCard(delivery),
              ],

            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: DeliveryTheme.navyDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3D0F172A),
                    offset: Offset(0, -6),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildActionButton(delivery, state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMapCard(DeliveryOrder delivery) {
    final farmerPos = (delivery.farmerLatitude != null && delivery.farmerLongitude != null)
        ? LatLng(delivery.farmerLatitude!, delivery.farmerLongitude!)
        : (delivery.pickupAddress?.latitude != null && delivery.pickupAddress?.longitude != null
            ? LatLng(delivery.pickupAddress!.latitude!, delivery.pickupAddress!.longitude!)
            : const LatLng(16.5162, 80.6380));

    final customerPos = (delivery.customerLatitude != null && delivery.customerLongitude != null)
        ? LatLng(delivery.customerLatitude!, delivery.customerLongitude!)
        : (delivery.deliveryAddress?.latitude != null && delivery.deliveryAddress?.longitude != null
            ? LatLng(delivery.deliveryAddress!.latitude!, delivery.deliveryAddress!.longitude!)
            : const LatLng(16.5062, 80.6480));

    final isHeadingToCustomer = delivery.status == DeliveryOrderStatus.pickedUp ||
        delivery.status == DeliveryOrderStatus.outForDelivery;

    final LatLng center = isHeadingToCustomer ? customerPos : farmerPos;


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: center != null
                  ? Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 13,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: AppConstants.mapTileUrl,
                              userAgentPackageName: 'com.farmfresh.app',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: farmerPos,
                                width: 34,
                                height: 34,
                                child: const Icon(Icons.agriculture, color: Color(0xFFEA580C), size: 28),
                              ),
                              Marker(
                                point: customerPos,
                                width: 34,
                                height: 34,
                                child: const Icon(Icons.home, color: Color(0xFF10B981), size: 28),
                              ),
                            ]),
                          ],
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: MapZoomControls(mapController: _mapController),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.green.shade50,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 40, color: Colors.green),
                            const SizedBox(height: 4),
                            Text(
                              'Route Navigation Overview',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRouteMeta('EST. DISTANCE', '${(delivery.distance ?? 3.5).toStringAsFixed(1)} km'),
                _buildRouteMeta('EST. EARNINGS', '₹${(delivery.deliveryFee ?? 50.0).toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
      ],
    );
  }

  Widget _buildLocationsTimeline(DeliveryOrder delivery) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline & Delivery Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.store, color: Colors.blue),
                    Container(height: 40, width: 2, color: Colors.grey.shade300),
                    const Icon(Icons.location_on, color: Colors.green),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PICKUP (FARMER)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery.farmer?.farmName ?? 'Swarna Bharat Farms',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        delivery.pickupAddress?.street ?? 'House No. 12, Main Street, Guntur, AP',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'DROP OFF (CUSTOMER)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery.customer?.name ?? 'Jane Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        delivery.deliveryAddress?.street ?? 'No Drop-off address details',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(DeliveryOrder delivery) {
    final list = delivery.items ?? [];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Package Items List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 24),
            if (list.isEmpty)
              const Text('No items detailed in payload.', style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerCard(DeliveryOrder delivery) {
    final farmerName = delivery.farmer?.farmName ?? delivery.farmer?.name ?? 'Swarna Organic Farms';
    final farmerContact = delivery.farmer?.name ?? 'Ramesh Patel (Farmer)';
    final farmerPhone = (delivery.farmer?.phone != null && delivery.farmer!.phone.isNotEmpty) ? delivery.farmer!.phone : '+91 98480 22338';
    final pickupStreet = delivery.pickupAddress?.street ?? 'Swarna Organic Farms, NH-16 Bypass, Guntur, AP';

    return Container(
      decoration: DeliveryTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.agriculture_rounded, color: DeliveryTheme.orangePrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FARMER PICKUP CONTACT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: DeliveryTheme.orangePrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      farmerName,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: DeliveryTheme.navyDark),
                    ),
                    Text(
                      'Contact: $farmerContact • $farmerPhone',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: Color(0xFF10B981), size: 18),
                ),
                onPressed: () {
                  showAppSnackBar(context, 'Calling Farmer: $farmerPhone', type: SnackBarType.info);
                },
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pickupStreet,
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(DeliveryOrder delivery) {
    final customerName = delivery.customer?.name ?? 'Anil Kumar';
    final customerPhone = (delivery.customer?.phone != null && delivery.customer!.phone.isNotEmpty) ? delivery.customer!.phone : '+91 91234 56789';
    final dropStreet = delivery.deliveryAddress?.street ?? 'Flat 402, Koritepadu, Guntur, AP 522001';

    return Container(
      decoration: DeliveryTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin_circle_rounded, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOMER DROP-OFF CONTACT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: DeliveryTheme.navyDark),
                    ),
                    Text(
                      'Phone: $customerPhone',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: Color(0xFF10B981), size: 18),
                ),
                onPressed: () {
                  showAppSnackBar(context, 'Calling Customer: $customerPhone', type: SnackBarType.info);
                },
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dropStreet,
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton(DeliveryOrder delivery, DeliveryOrdersState state) {
    if (state.isPerformingAction) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (delivery.status) {
      case DeliveryOrderStatus.pending:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _acceptJob(delivery.id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Accept Delivery Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      case DeliveryOrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), foregroundColor: Colors.green),
                  child: const Text('Open Map / GPS'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _markPickedUp(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Start Route to Farm', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.headingToPickup:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), foregroundColor: Colors.green),
                  child: const Text('Open Map / GPS'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _confirmPickup(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('Confirm Pickup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.pickedUp:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  icon: const Icon(Icons.navigation_outlined, color: DeliveryTheme.orangePrimary),
                  label: Text('Open GPS Map', style: GoogleFonts.plusJakartaSans(color: DeliveryTheme.orangePrimary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: DeliveryTheme.orangePrimary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _startTransit(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: DeliveryTheme.orangePrimary, foregroundColor: Colors.white),
                  child: const Text('Start Transit', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.outForDelivery:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/delivery-navigation', extra: delivery),
                  icon: const Icon(Icons.navigation_outlined, color: DeliveryTheme.orangePrimary),
                  label: Text('Open GPS Map', style: GoogleFonts.plusJakartaSans(color: DeliveryTheme.orangePrimary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: DeliveryTheme.orangePrimary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _showOtpDialog(delivery.id),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  child: const Text('Verify Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      case DeliveryOrderStatus.delivered:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Delivery Completed Successfully', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.rejected:
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Delivery Assignment Inactive', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
    }
  }

  void _acceptJob(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).acceptDelivery(id);
    if (mounted && ok) {
      showAppSnackBar(
        context,
        'Job accepted! Routing to farm...',
        type: SnackBarType.success,
      );
    }
  }

  void _markPickedUp(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).markPickedUp(id);
    if (mounted && ok) {
      ref.read(deliveryTrackingServiceProvider).startTracking(id);
      showAppSnackBar(
        context,
        'Route to farm started!',
        type: SnackBarType.success,
      );
    }
  }

  void _confirmPickup(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).confirmPickup(id);
    if (mounted && ok) {
      showAppSnackBar(
        context,
        'Packages picked up. Ready for transit!',
        type: SnackBarType.info,
      );
    }
  }

  void _startTransit(String id) async {
    final ok = await ref.read(deliveryOrdersProvider.notifier).startDelivery(id);
    if (mounted && ok) {
      ref.read(deliveryTrackingServiceProvider).startTracking(id);
      showAppSnackBar(
        context,
        'Transit started. Heading to customer drop-off.',
        type: SnackBarType.info,
      );
    }
  }

  void _showOtpDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Delivery OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please collect the 6-digit OTP code displayed on the customer\'s order tracking screen to complete last-mile validation.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-Digit OTP Code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
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
              final otp = _otpController.text.trim();
              if (otp.length != 6) {
                showAppSnackBar(
                  context,
                  'Please enter a valid 6-digit OTP code.',
                  type: SnackBarType.error,
                );
                return;
              }
              Navigator.pop(context);
              final ok = await ref.read(deliveryOrdersProvider.notifier).verifyOtp(id, otp);
              if (mounted) {
                if (ok) {
                  ref.read(deliveryTrackingServiceProvider).stopTracking();
                  showAppSnackBar(
                    context,
                    'Order verified and delivered!',
                    type: SnackBarType.success,
                  );
                  context.pop();
                } else {
                  showAppSnackBar(
                    context,
                    'Invalid OTP code. Please retry.',
                    type: SnackBarType.error,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Verify Code'),
          ),
        ],
      ),
    );
  }
}
