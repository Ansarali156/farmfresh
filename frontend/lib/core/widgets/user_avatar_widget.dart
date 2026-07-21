import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';

class UserAvatarWidget extends StatelessWidget {
  final UserModel? user;
  final double size;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    required this.user,
    this.size = 38.0,
    this.onTap,
  });

  static String getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFFE50914), // Netflix Red
      const Color(0xFF0071EB), // Blue
      const Color(0xFFF4B400), // Yellow
      const Color(0xFF0F9D58), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarStr = user?.avatar;
    final userName = user?.name ?? 'User';
    final initials = getInitials(userName);
    final bgColor = getAvatarColor(userName);

    Widget avatarContent;

    if (avatarStr != null && avatarStr.isNotEmpty) {
      if (avatarStr.startsWith('emoji:')) {
        final emoji = avatarStr.replaceFirst('emoji:', '');
        avatarContent = Container(
          color: const Color(0xFFE8F5E9),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.55),
            ),
          ),
        );
      } else if (avatarStr.startsWith('http')) {
        avatarContent = CachedNetworkImage(
          imageUrl: avatarStr,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: bgColor,
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, err) => Container(
            color: bgColor,
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ),
          ),
        );
      } else if (avatarStr.contains(',') || avatarStr.length > 50) {
        try {
          final cleanBase64 = avatarStr.contains(',') ? avatarStr.split(',')[1] : avatarStr;
          avatarContent = Image.memory(
            base64Decode(cleanBase64),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitials(initials, bgColor),
          );
        } catch (_) {
          avatarContent = _buildInitials(initials, bgColor);
        }
      } else {
        avatarContent = _buildInitials(initials, bgColor);
      }
    } else {
      avatarContent = _buildInitials(initials, bgColor);
    }

    final container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2E5C45),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipOval(child: avatarContent),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }

  Widget _buildInitials(String initials, Color bgColor) {
    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
