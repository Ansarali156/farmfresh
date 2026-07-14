import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/delivery_model.dart';

class DeliveryNavigationScreen extends StatelessWidget {
  final DeliveryOrder delivery;

  const DeliveryNavigationScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final destination = delivery.deliveryAddress;
    final address = destination?.fullAddress ?? 'Delivery location';

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
            'Delivery Route Map',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF23312B)),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone_outlined, color: Color(0xFF23312B)),
              onPressed: () => _callCustomer(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A2E5C45),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Decorative background simulating a map
                      Container(
                        color: const Color(0xFFFAFBF9),
                        child: Center(
                          child: Opacity(
                            opacity: 0.05,
                            child: Icon(Icons.map_outlined, size: 200, color: const Color(0xFF2E7D32)),
                          ),
                        ),
                      ),
                      // Core routing info indicator
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2), width: 3),
                              ),
                              child: const Icon(Icons.navigation_outlined, size: 40, color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Routing Engine Ready',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                address,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 11, height: 1.4),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFE28C43), Color(0xFFF3A05B)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _openGoogleMaps(),
                                icon: const Icon(Icons.directions_outlined, size: 16),
                                label: Text(
                                  'Launch in Google Maps',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F2E5C45),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (delivery.distance != null) ...[
                    const Icon(Icons.straighten_outlined, color: Color(0xFF647C72), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${delivery.distance!.toStringAsFixed(1)} km away',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (delivery.estimatedDeliveryTime != null) ...[
                    const Icon(Icons.access_time_outlined, color: Color(0xFF647C72), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${delivery.estimatedDeliveryTime}',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EN ROUTE',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontSize: 8, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (delivery.customer != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0F2EF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.customer!.name,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF23312B)),
                        ),
                        Text(
                          delivery.customer!.phone,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF647C72), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _callCustomer(context),
                    icon: const Icon(Icons.phone_in_talk_outlined, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openGoogleMaps(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF219EBC),
                    side: const BorderSide(color: Color(0xFF219EBC)),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Directions',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF647C72),
                    side: const BorderSide(color: Color(0xFFECECEC)),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps() async {
    final address = delivery.deliveryAddress?.fullAddress ?? '';
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _callCustomer(BuildContext context) {
    final phone = delivery.customer?.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No phone number available', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFFFB703),
        ),
      );
      return;
    }
    launchUrl(Uri.parse('tel:$phone'));
  }
}
