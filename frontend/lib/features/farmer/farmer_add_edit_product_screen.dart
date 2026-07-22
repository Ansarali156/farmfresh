import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/theme/colors.dart';

class FarmerAddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product;

  const FarmerAddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<FarmerAddEditProductScreen> createState() => _FarmerAddEditProductScreenState();
}

class _FarmerAddEditProductScreenState extends ConsumerState<FarmerAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _weightController;
  late final TextEditingController _originController;
  late final TextEditingController _imageController;
  
  late String _selectedCategory;
  late String _availabilityStatus;

  bool _isOrganic = false;
  bool _isFeatured = false;
  bool _isSeasonal = false;
  bool _isSaving = false;
  bool _isGeneratingAi = false;
  bool _isUploadingImage = false;

  Uint8List? _pickedImageBytes;
  String? _pickedImageFilename;

  // AI Assistant Engine State
  String _aiSuggestedPrice = '';
  List<String> _aiKeywords = [];
  Map<String, String> _aiSpecs = {};
  int _listingHealthScore = 60;
  String? _aiCategorySuggestion;

  bool get _isEditMode => widget.product != null;

  static const List<String> AVAILABILITY_OPTIONS = [
    'APPROVED',
    'ACTIVE',
    'IN_STOCK',
    'OUT_OF_STOCK',
    'PENDING',
    'REJECTED',
    'HIDDEN'
  ];

  static String suggestImage(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=600';
    if (lower.contains('onion')) return 'https://images.unsplash.com/photo-1618512496248-a07fe83766a5?w=600';
    if (lower.contains('mango')) return 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600';
    if (lower.contains('rice')) return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600';
    if (lower.contains('apple')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600';
    if (lower.contains('carrot')) return 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600';
    if (lower.contains('milk')) return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600';
    if (lower.contains('egg')) return 'https://images.unsplash.com/photo-1516448424440-9dbca97779c1?w=600';
    if (lower.contains('banana')) return 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600';
    if (lower.contains('potato')) return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600';
    if (lower.contains('orange')) return 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600';
    if (lower.contains('lemon')) return 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=600';
    if (lower.contains('strawberry')) return 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600';
    if (lower.contains('grapes')) return 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600';
    if (lower.contains('watermelon')) return 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600';
    if (lower.contains('chili') || lower.contains('chilli')) return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600';
    if (lower.contains('cabbage')) return 'https://images.unsplash.com/photo-1582515073490-39981397c445?w=600';
    if (lower.contains('spinach')) return 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600';
    return 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=600';
  }


  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.originalPrice.toStringAsFixed(0) : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toStringAsFixed(0) : '');
    _weightController = TextEditingController(text: p?.weight ?? '1 kg');
    _originController = TextEditingController(text: p?.origin ?? 'Local Farm');
    _imageController = TextEditingController(text: p?.image ?? '');
    final categories = ['Vegetables', 'Fruits', 'Grains & Millets', 'Dairy', 'Organic Goods'];
    final rawCategory = p?.category ?? 'Vegetables';
    _selectedCategory = categories.contains(rawCategory) ? rawCategory : 'Vegetables';
    _availabilityStatus = p?.status ?? 'PENDING_APPROVAL';
    _isOrganic = p?.organic ?? true;
    _isFeatured = p?.featured ?? false;
    _isSeasonal = p?.seasonal ?? false;

    _nameController.addListener(_onNameChanged);
    _descriptionController.addListener(_recalculateHealthScore);
    _priceController.addListener(_recalculateHealthScore);

    if (_nameController.text.isNotEmpty) {
      _runAiAnalysis(_nameController.text);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _descriptionController.removeListener(_recalculateHealthScore);
    _priceController.removeListener(_recalculateHealthScore);
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    if (name.length > 2) {
      if (_imageController.text.isEmpty || _imageController.text.contains('unsplash')) {
        _imageController.text = suggestImage(name);
      }
      _runAiAnalysis(name);
    }
  }

  void _runAiAnalysis(String name) {
    final lower = name.toLowerCase();
    
    // Category Auto-suggestion
    if (lower.contains('apple') || lower.contains('mango') || lower.contains('banana') || lower.contains('orange') || lower.contains('grape')) {
      _aiCategorySuggestion = 'Fruits';
    } else if (lower.contains('rice') || lower.contains('wheat') || lower.contains('millet') || lower.contains('grain')) {
      _aiCategorySuggestion = 'Grains & Millets';
    } else if (lower.contains('milk') || lower.contains('curd') || lower.contains('paneer') || lower.contains('cheese') || lower.contains('ghee')) {
      _aiCategorySuggestion = 'Dairy';
    } else {
      _aiCategorySuggestion = 'Vegetables';
    }

    // AI Pricing range suggestion
    if (lower.contains('tomato')) {
      _aiSuggestedPrice = '₹35 - ₹55 / kg';
    } else if (lower.contains('mango')) {
      _aiSuggestedPrice = '₹120 - ₹180 / kg';
    } else if (lower.contains('rice')) {
      _aiSuggestedPrice = '₹60 - ₹95 / kg';
    } else if (lower.contains('milk')) {
      _aiSuggestedPrice = '₹50 - ₹70 / L';
    } else {
      _aiSuggestedPrice = '₹40 - ₹80 / unit';
    }

    // AI Smart Tags
    _aiKeywords = [
      '#FarmFresh',
      '#100%Organic',
      if (_isOrganic) '#PesticideFree',
      '#A-GradeQuality',
      '#LocallyHarvested',
      if (_isSeasonal) '#SeasonalSpecial'
    ];

    // AI Specs auto fill
    _aiSpecs = {
      'Calories': lower.contains('mango') ? '60 kcal/100g' : (lower.contains('rice') ? '130 kcal/100g' : '18 kcal/100g'),
      'Vitamins': 'Vitamin A, C, Potassium',
      'Shelf Life': lower.contains('milk') ? '3 Days (Refrigerated)' : '7 - 10 Days',
      'Harvest Date': 'Harvested Fresh Today'
    };

    _recalculateHealthScore();
  }

  void _recalculateHealthScore() {
    int score = 40;
    if (_nameController.text.trim().length > 3) score += 15;
    if (_descriptionController.text.trim().length > 20) score += 20;
    if (_priceController.text.trim().isNotEmpty && double.tryParse(_priceController.text) != null && double.parse(_priceController.text) > 0) score += 15;
    if (_imageController.text.trim().isNotEmpty) score += 10;
    setState(() {
      _listingHealthScore = score.clamp(0, 100);
    });
  }

  Future<void> _handleAutoGenerateDescription() async {
    if (_nameController.text.trim().isEmpty) {
      showAppSnackBar(context, 'Please enter a product name first', type: SnackBarType.warning);
      return;
    }
    setState(() => _isGeneratingAi = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final name = _nameController.text.trim();
    final generated = 'Fresh, premium quality $name sourced directly from verified local farms. Hand-harvested at peak ripeness, naturally grown without synthetic pesticides or harmful chemicals. Rich in vital nutrients, vitamins, and natural flavor. Perfect for healthy daily home meals, gourmet cooking, and family wellness.';
    
    setState(() {
      _descriptionController.text = generated;
      _isGeneratingAi = false;
    });

    showAppSnackBar(context, 'AI Description generated successfully!', type: SnackBarType.success);
  }

  static const _allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
  static const _maxFileSize = 5 * 1024 * 1024;

  Future<void> _pickProductImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';

      if (!_allowedMimeTypes.contains(mimeType)) {
        if (mounted) {
          showAppSnackBar(context, 'Unsupported file type. Please choose JPG, PNG, or WebP.', type: SnackBarType.error);
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      if (bytes.length > _maxFileSize) {
        if (mounted) {
          showAppSnackBar(context, 'File too large. Maximum size is 5MB.', type: SnackBarType.error);
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      final ext = pickedFile.name.split('.').last.toLowerCase();
      final filename = 'product_${DateTime.now().millisecondsSinceEpoch}.$ext';

      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageFilename = filename;
        _imageController.text = '';
        _isUploadingImage = false;
      });

      if (mounted) {
        showAppSnackBar(context, 'Image selected successfully', type: SnackBarType.success);
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        showAppSnackBar(context, 'Failed to pick image: $e', type: SnackBarType.error);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(context, 'Please fix validation errors first', type: SnackBarType.error);
      return;
    }

    setState(() => _isSaving = true);

    final categories = ref.read(categoryProvider).categories;
    final matchedCategory = categories.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCategory.toLowerCase(),
      orElse: () => categories.isNotEmpty ? categories.first : CategoryModel(id: '', name: '', slug: ''),
    );

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      originalPrice: widget.product?.originalPrice ?? double.parse(_priceController.text),
      stock: double.parse(_stockController.text),
      weight: _weightController.text.trim(),
      category: _selectedCategory,
      origin: _originController.text.trim(),
      organic: _isOrganic,
      featured: _isFeatured,
      seasonal: _isSeasonal,
      image: _pickedImageBytes != null
          ? (_imageController.text.trim().isNotEmpty ? _imageController.text.trim() : suggestImage(_nameController.text.trim()))
          : (_imageController.text.trim().isNotEmpty ? _imageController.text.trim() : suggestImage(_nameController.text.trim())),
      farmName: widget.product?.farmName ?? 'Green Valley Organic Farms',
      farmerId: widget.product?.farmerId,
      slug: widget.product?.slug ?? '',
      categoryId: matchedCategory.id.isNotEmpty ? matchedCategory.id : widget.product?.categoryId,
      status: _isEditMode ? (_availabilityStatus == 'HIDDEN' ? 'ARCHIVED' : (widget.product?.status ?? 'APPROVED')) : 'PENDING_APPROVAL',
    );

    bool success;
    if (_isEditMode) {
      success = await ref.read(productProvider.notifier).updateProduct(
        product,
        imageBytes: _pickedImageBytes,
        imageFilename: _pickedImageFilename,
      );
    } else {
      success = await ref.read(productProvider.notifier).addProduct(
        product,
        imageBytes: _pickedImageBytes,
        imageFilename: _pickedImageFilename,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showAppSnackBar(
        context,
        _isEditMode ? 'Product updated successfully' : 'Product submitted for Admin Approval!',
        type: SnackBarType.success,
      );
      context.pop();
    }
 else {
      showAppSnackBar(context, 'Failed to save product. Please try again.', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x0F000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF23312B)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _isEditMode ? 'Edit Product' : 'Add New Product',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF23312B),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'AI Powered',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Publish fresh agricultural produce with automated AI listing optimization',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF647C72),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),

              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildFormCard(categoryState)),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildAiAssistantPanel()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildAiAssistantPanel(),
                        const SizedBox(height: 20),
                        _buildFormCard(categoryState),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(dynamic categoryState) {
    final hasPickedBytes = _pickedImageBytes != null && _pickedImageBytes!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECECEC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2E5C45),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          padding: EdgeInsets.all(isNarrow ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover Image Upload Box (Admin Portal Style)
              Text('Product Cover Image', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF23312B))),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(isNarrow ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD8E8DC), style: BorderStyle.solid),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: hasPickedBytes
                            ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                            : _imageController.text.isNotEmpty
                                ? Image.network(
                                    _imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.cloud_upload_outlined, color: Color(0xFF647C72), size: 36),
                                  )
                                : const Icon(Icons.cloud_upload_outlined, color: Color(0xFF647C72), size: 36),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isNarrow ? double.infinity : 320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cover Image Preview', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF23312B))),
                          const SizedBox(height: 2),
                          Text(
                            hasPickedBytes ? 'Custom image selected' : 'Auto-suggested from produce name or upload custom image',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF647C72)),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _isUploadingImage ? null : _pickProductImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF2E7D32)))
                                    : Icon(hasPickedBytes ? Icons.swap_horiz : Icons.photo_camera, size: 16, color: const Color(0xFF2E7D32)),
                                label: Text(_isUploadingImage ? 'Selecting...' : (hasPickedBytes ? 'Replace Image' : 'Choose File'), style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF2E7D32)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Custom Image URL field
              TextFormField(
                controller: _imageController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF23312B)),
                decoration: _adminInputDecoration('Image URL', Icons.link),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // 2. Product Name & Category
              if (isNarrow) ...[
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                  decoration: _adminInputDecoration('Product Name *', Icons.spa_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['Vegetables', 'Fruits', 'Grains & Millets', 'Dairy', 'Organic Goods'].contains(_selectedCategory)
                      ? _selectedCategory
                      : 'Vegetables',
                  decoration: _adminInputDecoration('Category *', Icons.category_outlined),
                  items: ['Vegetables', 'Fruits', 'Grains & Millets', 'Dairy', 'Organic Goods']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Product Name *', Icons.spa_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: ['Vegetables', 'Fruits', 'Grains & Millets', 'Dairy', 'Organic Goods'].contains(_selectedCategory)
                            ? _selectedCategory
                            : 'Vegetables',
                        decoration: _adminInputDecoration('Category *', Icons.category_outlined),
                        items: ['Vegetables', 'Fruits', 'Grains & Millets', 'Dairy', 'Organic Goods']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),
              if (_aiCategorySuggestion != null && _aiCategorySuggestion != _selectedCategory) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _aiCategorySuggestion!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFE28C43), size: 12),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'AI Suggestion: Switch category to "$_aiCategorySuggestion"? (Tap to apply)',
                            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE28C43), fontSize: 11, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // 3. Description Field with Auto-Generate AI Button (Zero Overflow Wrap)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text('Product Description *', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF647C72))),
                  TextButton.icon(
                    onPressed: _isGeneratingAi ? null : _handleAutoGenerateDescription,
                    icon: _isGeneratingAi
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)))
                        : const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF2E7D32)),
                    label: Text(
                      _isGeneratingAi ? 'Generating...' : 'Auto-generate AI Description',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF23312B)),
                decoration: _adminInputDecoration('Describe fresh produce quality, origin & uses', Icons.description_outlined).copyWith(alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // 4. Pricing & Stock & Unit Size (Adaptive Layout)
              if (isNarrow) ...[
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                  decoration: _adminInputDecoration('Price *', Icons.currency_rupee).copyWith(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null) ? 'Enter valid price' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Stock Qty *', Icons.inventory_2_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null) ? 'Enter stock' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Unit Size *', Icons.scale_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter unit' : null,
                      ),
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Price *', Icons.currency_rupee).copyWith(
                          prefixText: '₹ ',
                          prefixStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null) ? 'Enter valid price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Stock Qty *', Icons.inventory_2_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty || double.tryParse(v) == null) ? 'Enter stock' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _weightController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Unit Size *', Icons.scale_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter unit' : null,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // 5. Origin & Availability Status (Adaptive Layout)
              if (isNarrow) ...[
                TextFormField(
                  controller: _originController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF23312B)),
                  decoration: _adminInputDecoration('Farm Origin', Icons.location_on_outlined),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _availabilityStatus,
                  decoration: _adminInputDecoration('Status', Icons.check_circle_outline),
                  items: AVAILABILITY_OPTIONS
                      .map((opt) => DropdownMenuItem(value: opt, child: Text(opt.replaceAll('_', ' '), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _availabilityStatus = val);
                  },
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _originController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF23312B)),
                        decoration: _adminInputDecoration('Farm Origin', Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _availabilityStatus,
                        decoration: _adminInputDecoration('Status', Icons.check_circle_outline),
                        items: AVAILABILITY_OPTIONS
                            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt.replaceAll('_', ' '), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _availabilityStatus = val);
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // 6. Badges & Switches (Wrap for Zero Overflow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2EFE5)),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildSwitchOption('Organic Certified', _isOrganic, (v) => setState(() => _isOrganic = v)),
                    _buildSwitchOption('Featured Item', _isFeatured, (v) => setState(() => _isFeatured = v)),
                    _buildSwitchOption('Seasonal Crop', _isSeasonal, (v) => setState(() => _isSeasonal = v)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 7. Submit Action Buttons (Wrap for Zero Overflow)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProduct,
                    icon: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.publish, color: Colors.white, size: 18),
                    label: Text(
                      _isSaving ? 'Saving...' : (_isEditMode ? 'Update Product' : 'Save & Publish Product'),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.farmerPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiAssistantPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 10),
            blurRadius: 28,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4ADE80), width: 1.5),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF4ADE80), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FarmFresh AI Assistant',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Smart listing optimization & quality analysis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Listing Quality Health Score Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF475569)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Listing Quality Score', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFFE2E8F0))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _listingHealthScore >= 80 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_listingHealthScore% Excellent',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _listingHealthScore / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF475569),
                    color: _listingHealthScore >= 80 ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Market Price Recommendation Card
          if (_aiSuggestedPrice.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Color(0xFF38BDF8), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Market Pricing Guidance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF7DD3FC))),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated Market Rate: $_aiSuggestedPrice',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // SEO Keywords & Smart Tags
          Text('AI Smart Tags & SEO Keywords', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _aiKeywords.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Text(tag, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Auto-filled Nutritional Specifications Card
          if (_aiSpecs.isNotEmpty) ...[
            Text('Auto-filled Produce Specifications', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: _aiSpecs.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8))),
                      Text(e.value, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF1F5F9))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _adminInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF647C72)),
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 18),
      filled: true,
      fillColor: const Color(0xFFF9FBF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
    );
  }

  Widget _buildSwitchOption(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D32),
          ),
        ),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF23312B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}