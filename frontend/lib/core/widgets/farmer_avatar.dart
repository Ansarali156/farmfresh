import 'package:flutter/material.dart';

class FarmerAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;

  const FarmerAvatar({
    super.key,
    required this.avatarUrl,
    required this.radius,
  });

  bool _isEmoji(String str) {
    if (str.isEmpty) return false;
    return str.length <= 4 &&
        !str.startsWith('http') &&
        !str.startsWith('data') &&
        !str.startsWith('/') &&
        !str.startsWith('assets');
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl ?? '';

    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8F5E9),
        child: Icon(
          Icons.person,
          size: radius * 1.0,
          color: const Color(0xFF2E7D32),
        ),
      );
    }

    if (_isEmoji(url)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8F5E9),
        child: Text(
          url,
          style: TextStyle(
            fontSize: radius * 1.1,
          ),
        ),
      );
    }

    // Otherwise render image
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
      backgroundColor: const Color(0xFFE8F5E9),
      onBackgroundImageError: (_, __) => Icon(
        Icons.person,
        size: radius * 1.0,
        color: const Color(0xFF2E7D32),
      ),
    );
  }
}

class FarmerAvatarPreset {
  final String id;
  const FarmerAvatarPreset({required this.id});
}

class FarmerAvatarPresets {
  static const List<FarmerAvatarPreset> presets = [
    FarmerAvatarPreset(id: '🍎'),
    FarmerAvatarPreset(id: '🍏'),
    FarmerAvatarPreset(id: '🍊'),
    FarmerAvatarPreset(id: '🍋'),
    FarmerAvatarPreset(id: '🍌'),
    FarmerAvatarPreset(id: '🍉'),
    FarmerAvatarPreset(id: '🍓'),
    FarmerAvatarPreset(id: '🍒'),
    FarmerAvatarPreset(id: '🥭'),
    FarmerAvatarPreset(id: '🍍'),
    FarmerAvatarPreset(id: '🍇'),
    FarmerAvatarPreset(id: '🍅'),
    FarmerAvatarPreset(id: '🥑'),
    FarmerAvatarPreset(id: '🥕'),
    FarmerAvatarPreset(id: '🌽'),
    FarmerAvatarPreset(id: '🥦'),
    FarmerAvatarPreset(id: '🥬'),
    FarmerAvatarPreset(id: '🥔'),
    FarmerAvatarPreset(id: '🧅'),
    FarmerAvatarPreset(id: '🍄'),
  ];
}
