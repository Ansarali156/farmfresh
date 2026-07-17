import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 25.0, // Default to rounded pill shape
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    // Colors
    final Color primaryColor = widget.backgroundColor ?? const Color(0xFF2E7D32);
    final Color secondaryColor = widget.backgroundColor != null 
        ? widget.backgroundColor!.withOpacity(0.8) 
        : const Color(0xFF1B4332);
    final Color textCol = widget.textColor ?? (widget.isOutlined ? primaryColor : Colors.white);

    // Build internal elements
    Widget contentRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textCol,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: textCol),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: GoogleFonts.plusJakartaSans(
            color: textCol,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    // Styling
    BoxDecoration decoration;
    if (widget.isOutlined) {
      decoration = BoxDecoration(
        color: _isHovered ? primaryColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: primaryColor.withOpacity(0.5),
          width: 1.5,
        ),
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDisabled
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [
                  _isHovered ? primaryColor.withOpacity(0.95) : primaryColor,
                  _isHovered ? secondaryColor.withOpacity(0.95) : secondaryColor,
                ],
        ),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _scale = 0.96),
        onTapUp: isDisabled ? null : (_) {
          setState(() => _scale = 1.0);
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: decoration,
            child: Stack(
              children: [
                // Glossy sheen
                if (!widget.isOutlined && !isDisabled)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.18),
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Label & Icon
                Center(
                  child: contentRow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
