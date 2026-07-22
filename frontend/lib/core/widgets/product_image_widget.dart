import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final String? productName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.productName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  String get _fullImageUrl {
    if (imageUrl.isNotEmpty &&
        !imageUrl.contains('storageapi.dev') &&
        (imageUrl.startsWith('http://') ||
            imageUrl.startsWith('https://') ||
            imageUrl.startsWith('blob:') ||
            imageUrl.startsWith('data:'))) {
      return imageUrl;
    }

    final name = (productName ?? '').toLowerCase();

    if (name.contains('tomato')) return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500';
    if (name.contains('apple')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500';
    if (name.contains('carrot')) return 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=500';
    if (name.contains('broccol') || name.contains('cauliflow')) return 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=500';
    if (name.contains('strawberr')) return 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500';
    if (name.contains('mango')) return 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500';
    if (name.contains('milk')) return 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500';
    if (name.contains('cheese') || name.contains('paneer') || name.contains('butter')) return 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500';
    if (name.contains('spinach') || name.contains('green') || name.contains('leaf') || name.contains('palak')) return 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500';
    if (name.contains('onion')) return 'https://images.unsplash.com/photo-1618512496248-a07fe83766a5?w=500';
    if (name.contains('potato')) return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500';
    if (name.contains('banana')) return 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500';
    if (name.contains('chicken') || name.contains('meat') || name.contains('beef') || name.contains('mutton')) return 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500';
    if (name.contains('egg')) return 'https://images.unsplash.com/photo-1516448424440-9dbca97779c1?w=500';
    if (name.contains('rice') || name.contains('grain') || name.contains('wheat') || name.contains('dal')) return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500';
    if (name.contains('orange')) return 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=500';
    if (name.contains('grape')) return 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=500';

    if (imageUrl.startsWith('/')) {
      final uri = Uri.parse(AppConstants.apiBaseUrl);
      final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
      return '$baseUrl$imageUrl';
    }

    final pool = [
      'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500',
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
      'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=500',
      'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=500',
      'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500',
      'https://images.unsplash.com/photo-1573246123716-6b1782bfc499?w=500',
      'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=500',
      'https://images.unsplash.com/photo-1506459225024-1428097a7e18?w=500',
    ];

    final index = (productName ?? imageUrl).hashCode.abs() % pool.length;
    return pool[index];
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        _fullImageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(Icons.spa, color: Color(0xFF2E7D32), size: 30),
      ),
    );
  }
}
