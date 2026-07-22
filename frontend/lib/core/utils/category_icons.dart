import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized category icon mapping for consistent category visuals
/// across the entire FarmFresh application.
///
/// Usage:
///   CategoryIcons.getSvgWidget('Fruits', size: 24)
///   CategoryIcons.assetPath('Dairy')
class CategoryIcons {
  CategoryIcons._();

  static const String _basePath = 'assets/icons';

  /// Maps category names (case-insensitive) to their SVG asset paths.
  static const Map<String, String> _categoryAssets = {
    'fruits': '$_basePath/category_fruits.svg',
    'vegetables': '$_basePath/category_vegetables.svg',
    'grains': '$_basePath/category_grains.svg',
    'grains & millets': '$_basePath/category_grains.svg',
    'grains & cereals': '$_basePath/category_grains.svg',
    'dairy': '$_basePath/category_dairy.svg',
    'meat': '$_basePath/category_meat.svg',
    'organic': '$_basePath/category_organic.svg',
    'eggs': '$_basePath/category_eggs.svg',
    'herbs & greens': '$_basePath/category_organic.svg',
    'spices': '$_basePath/category_vegetables.svg',
    'more': '$_basePath/category_more.svg',
    'all': '$_basePath/category_all.svg',
    'all products': '$_basePath/category_all.svg',
  };

  /// Promo banner illustration asset paths.
  static const String promoFreshHarvest = '$_basePath/promo_fresh_harvest.svg';
  static const String promoFreeDelivery = '$_basePath/promo_free_delivery.svg';

  /// Returns the SVG asset path for the given category name.
  /// Falls back to the organic/leaf icon if category is not recognized.
  static String assetPath(String categoryName) {
    return _categoryAssets[categoryName.toLowerCase()] ??
        '$_basePath/category_organic.svg';
  }

  /// Returns an [SvgPicture] widget for the given category name.
  static Widget getSvgWidget(
    String categoryName, {
    double size = 28,
    BoxFit fit = BoxFit.contain,
    ColorFilter? colorFilter,
  }) {
    return SvgPicture.asset(
      assetPath(categoryName),
      width: size,
      height: size,
      fit: fit,
      colorFilter: colorFilter,
    );
  }

  /// Returns an [SvgPicture] widget for a promo illustration.
  static Widget getPromoSvg(
    String assetPathStr, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      assetPathStr,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
