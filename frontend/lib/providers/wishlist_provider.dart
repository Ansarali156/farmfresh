import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class WishlistNotifier extends StateNotifier<List<String>> {
  WishlistNotifier() : super([]) {
    _loadWishlist();
  }

  static const _key = 'wishlist_product_ids';
  final _storage = const FlutterSecureStorage();

  Future<void> _loadWishlist() async {
    final raw = await _storage.read(key: _key);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        state = decoded.cast<String>();
      }
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final current = List<String>.from(state);
    if (current.contains(productId)) {
      current.remove(productId);
    } else {
      current.add(productId);
    }
    await _storage.write(key: _key, value: jsonEncode(current));
    state = current;
  }

  bool isFavorited(String productId) {
    return state.contains(productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) {
  return WishlistNotifier();
});

// A derived provider that gets the actual ProductModel objects in the wishlist
final wishlistProductsProvider = Provider<List<ProductModel>>((ref) {
  final wishlistIds = ref.watch(wishlistProvider);
  final allProducts = ref.watch(productProvider).products;
  return allProducts.where((p) => wishlistIds.contains(p.id)).toList();
});
