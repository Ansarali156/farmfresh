import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/category_icons.dart';
import '../../core/widgets/user_avatar_widget.dart';
import '../../models/product_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  final PageController _bannerPageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF23312B),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomSheetListTile('All Products', const Color(0xFFE8F5E9), 'All'),
              _buildBottomSheetListTile('Fruits', const Color(0xFFFAD2E1), 'Fruits'),
              _buildBottomSheetListTile('Vegetables', const Color(0xFFEAF6EC), 'Vegetables'),
              _buildBottomSheetListTile('Grains & Millets', const Color(0xFFFFE5D9), 'Grains & Millets'),
              _buildBottomSheetListTile('Dairy', const Color(0xFFFFF1E6), 'Dairy'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetListTile(String title, Color bgColor, String category) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: CategoryIcons.getSvgWidget(category, size: 24),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(context);
        context.push('/products?category=$category');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final addressState = ref.watch(addressProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final cartState = ref.watch(cartProvider);
    final cartItemCount = cartState.itemCount;
    final defaultAddr = addressState.defaultAddress;
    final locationLabel = defaultAddr != null
        ? '${defaultAddr.city ?? defaultAddr.street}, ${defaultAddr.state ?? defaultAddr.country ?? 'India'}'
        : 'Bengaluru, India';

    final allProducts = productState.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Derived lists
    final freshNearYou = allProducts.take(8).toList();
    final todayDeals = allProducts.where((p) => p.discount != null).toList();
    final organicPicks = allProducts.where((p) => p.organic == true).toList();
    
    // Unique farmers derived from products
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: productState.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Color(0xFFE63946)),
                    const SizedBox(height: 12),
                    Text(productState.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(productProvider.notifier).loadProducts(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE28C43),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : productState.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : RefreshIndicator(
                  color: const Color(0xFF2E7D32),
                  onRefresh: () => ref.read(productProvider.notifier).loadProducts(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header
                          ClipPath(
                            clipper: UHeaderClipper(),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFEBF3EE),
                                    Color(0xFFFCF5EF),
                                    Color(0xFFE8F0FE),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.push('/addresses'),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x0F2E5C45),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.location_on, color: Color(0xFFE28C43), size: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Delivering to',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      color: const Color(0xFF647C72),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0xFF647C72)),
                                                ],
                                              ),
                                              Text(
                                                locationLabel,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF23312B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => context.push('/notifications'),
                                          child: const Icon(Icons.notifications_outlined, color: Color(0xFF23312B), size: 26),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            context.push('/cart');
                                          },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x0F2E5C45),
                                                      offset: Offset(0, 2),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32), size: 18),
                                                ),
                                              ),
                                              if (cartItemCount > 0)
                                                Positioned(
                                                  top: -2,
                                                  right: -2,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(3),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFE63946),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 14,
                                                      minHeight: 14,
                                                    ),
                                                    child: Text(
                                                      '$cartItemCount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        UserAvatarWidget(
                                          user: user,
                                          size: 38,
                                          onTap: () => context.push('/profile'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E7D32).withOpacity(0.06),
                                        offset: const Offset(0, 4),
                                        blurRadius: 16,
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.12), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  height: 52,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, color: Color(0xFF2E7D32), size: 22),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (val) {
                                            setState(() {
                                              _searchQuery = val;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Search fruits, vegetables...',
                                            hintStyle: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF647C72),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            filled: false,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                            isDense: true,
                                          ),
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF1B2E25),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
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

                        // Categories Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Categories', onTapSeeAll: _showCategoryBottomSheet),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCategoryItem('Fruits', const Color(0xFFFFCDD2), const Color(0xFFC9184A)),
                                  _buildCategoryItem('Vegetables', const Color(0xFFDCEDC8), const Color(0xFF2E7D32)),
                                  _buildCategoryItem('Grains', const Color(0xFFFFE5D9), const Color(0xFFD04A02)),
                                  _buildCategoryItem('Dairy', const Color(0xFFFFF9C4), const Color(0xFFE28C43)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCategoryItem('Meat', const Color(0xFFFFE0B2), const Color(0xFFD04A02)),
                                  _buildCategoryItem('Organic', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                                  _buildCategoryItem('Eggs', const Color(0xFFFFF1E6), const Color(0xFFE28C43)),
                                  _buildCategoryItem('More', const Color(0xFFE8F0FE), const Color(0xFF1976D2)),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Promo Banners Carousel
                              SizedBox(
                                height: 140,
                                child: PageView(
                                  children: [
                                    _buildPromoCard(
                                      badge: 'FRESH HARVEST',
                                      title: '50% OFF',
                                      subtitle: 'on your first order\nUse SAVE50',
                                      illustrationAsset: CategoryIcons.promoFreshHarvest,
                                      bgColor: const Color(0xFFFAF4EF),
                                      accentColor: const Color(0xFFE28C43),
                                    ),
                                    _buildPromoCard(
                                      badge: 'FREE DELIVERY',
                                      title: 'Free Local Delivery',
                                      subtitle: 'On fresh orders above ₹1600.00',
                                      illustrationAsset: CategoryIcons.promoFreeDelivery,
                                      bgColor: const Color(0xFFEAF3EE),
                                      accentColor: const Color(0xFF2E7D32),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildProductGrid(allProducts),
                          )
                        else ...[
                          // Fresh Near You
                          _buildHorizontalSection(
                            title: 'Fresh Near You',
                            products: freshNearYou,
                            onSeeAll: () => context.push('/products'),
                          ),

                          // Today's Deals
                          if (todayDeals.isNotEmpty)
                            _buildHorizontalSection(
                              title: "Today's Deals",
                              products: todayDeals,
                              onSeeAll: () => context.push('/products?discount=true'),
                            ),

                          // Organic Picks
                          if (organicPicks.isNotEmpty)
                            _buildHorizontalSection(
                              title: '🌿 Organic Picks',
                              products: organicPicks,
                              onSeeAll: () => context.push('/products?category=Organic'),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTapSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23312B),
          ),
        ),
        if (onTapSeeAll != null)
          GestureDetector(
            onTap: onTapSeeAll,
            child: Row(
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF647C72),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF647C72)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<ProductModel> products,
    required VoidCallback onSeeAll,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSectionHeader(title, onTapSeeAll: onSeeAll),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Enough height for ProductCard
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final prod = products[index];
              return SizedBox(
                width: 160,
                child: ProductCard(
                  product: prod,
                  onTap: () {
                    context.push('/product-details/${prod.id}', extra: prod);
                  },
                  onAddToCart: () {
                    ref.read(cartProvider.notifier).addItem(prod);
                    showAppSnackBar(
                      context,
                      'Added ${prod.name} to Cart',
                      type: SnackBarType.success,
                      actionLabel: 'Cart',
                      onAction: () {
                        context.push('/cart');
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }



  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No products match your search.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF647C72)),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return ProductCard(
          product: prod,
          onTap: () {
            context.push('/product-details/${prod.id}', extra: prod);
          },
          onAddToCart: () {
            ref.read(cartProvider.notifier).addItem(prod);
            showAppSnackBar(
              context,
              'Added ${prod.name} to Cart',
              type: SnackBarType.success,
              actionLabel: 'Cart',
              onAction: () {
                context.push('/cart');
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(String name, Color bgColor, Color activeColor) {
    return GestureDetector(
      onTap: () {
        context.push('/products?category=$name');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                color: activeColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: CategoryIcons.getSvgWidget(name, size: 34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2E25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String badge,
    required String title,
    required String subtitle,
    required String illustrationAsset,
    required Color bgColor,
    required Color accentColor,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFE28C43) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF647C72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: SvgPicture.asset(
              illustrationAsset,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class UHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    if (size.width <= 0 || size.height <= 24) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      size.width,
      size.height - 24,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
