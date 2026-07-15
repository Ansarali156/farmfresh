import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType { success, error, info, warning }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.success,
  Duration duration = const Duration(seconds: 2),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final Color bgColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      bgColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.error:
      bgColor = const Color(0xFFE63946);
      icon = Icons.error_outline_rounded;
      break;
    case SnackBarType.warning:
      bgColor = const Color(0xFFE28C43);
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
      bgColor = const Color(0xFF219EBC);
      icon = Icons.info_outline_rounded;
      break;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
}
