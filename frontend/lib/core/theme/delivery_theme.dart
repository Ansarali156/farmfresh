import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryTheme {
  // Primary Logistics Palette
  static const Color navyDark = Color(0xFF0F172A);
  static const Color navyPrimary = Color(0xFF1E293B);
  static const Color navyMedium = Color(0xFF334155);
  static const Color navyLight = Color(0xFF475569);

  // Express Orange Accent
  static const Color orangePrimary = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color orangeGlow = Color(0xFFFDBA74);

  // Status & Route Accents
  static const Color statusActive = Color(0xFF0284C7); // Sky Blue (In-Transit)
  static const Color statusPending = Color(0xFFF59E0B); // Amber (Pickup)
  static const Color statusDelivered = Color(0xFF10B981); // Emerald Green
  static const Color statusOffline = Color(0xFF64748B); // Slate Grey
  static const Color bgCanvas = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );

  static const LinearGradient statusOnlineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  // Card Decoration
  static BoxDecoration cardDecoration({Color? borderColor, Color? bgColor}) {
    return BoxDecoration(
      color: bgColor ?? Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor ?? cardBorder, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C0F172A),
          offset: Offset(0, 8),
          blurRadius: 20,
        ),
      ],
    );
  }

  // Status Badge Builder
  static Widget statusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'Delivered';
        icon = Icons.check_circle_outline;
        break;
      case 'IN_TRANSIT':
      case 'ON_THE_WAY':
      case 'OUT_FOR_DELIVERY':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        label = 'In Transit';
        icon = Icons.local_shipping_outlined;
        break;
      case 'PICKED_UP':
      case 'READY_FOR_PICKUP':
      case 'ARRIVED_AT_PICKUP':
      case 'ASSIGNED':
      case 'PREPARING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Pending Pickup';
        icon = Icons.storefront_outlined;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
