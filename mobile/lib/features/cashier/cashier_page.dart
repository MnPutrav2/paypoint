import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';
import 'package:kasir_offline/data/models/order_model.dart';
import 'package:kasir_offline/data/repositories/katalog_repository.dart';
import 'package:go_router/go_router.dart';

final _rupiahFmt = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

var categories = ['Semua'];

class CashierPage extends ConsumerStatefulWidget {
  const CashierPage({super.key});

  @override
  ConsumerState<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends ConsumerState<CashierPage> {
  List<KatalogItem> _katalog = [];
  bool _isLoading = true;
  int _selectedCategory = 0;
  String _searchQuery = '';
  final Map<String, KatalogItem> _cartItems = {};
  final Map<String, int> _cartQty = {};

  @override
  void initState() {
    super.initState();
    _loadKatalog();
  }

  Future<void> _loadKatalog() async {
    try {
      final repo = ref.read(katalogRepositoryProvider);
      final data = await repo.getKatalog();

      // Build kategori dari data real
      final cats = data.map((e) => e.kategori).toSet().toList();
      setState(() {
        _katalog = data;
        _isLoading = false;
        categories = ['Semua', ...cats];
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat katalog: $e')));
      }
    }
  }

  void _addToCart(KatalogItem item) {
    setState(() {
      _cartItems[item.id] = item;
      _cartQty[item.id] = (_cartQty[item.id] ?? 0) + 1;
    });
  }

  int get _totalItem => _cartQty.values.fold(0, (sum, qty) => sum + qty);

  List<KatalogItem> get _filtered => _katalog.where((k) {
    final matchCategory =
        _selectedCategory == 0 || k.kategori == categories[_selectedCategory];
    final matchSearch = k.nama.toLowerCase().contains(
      _searchQuery.toLowerCase(),
    );
    return matchCategory && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                // HEADER — sama seperti UI lama
                _buildHeader(),
                const SizedBox(height: 15),

                // SEARCH
                AppSearchBar(
                  hint: 'Cari produk...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),

                // CATEGORIES — dari data real
                AppCategoryTabs(
                  categories: categories,
                  selectedIndex: _selectedCategory,
                  onTap: (index) => setState(() => _selectedCategory = index),
                ),
                const SizedBox(height: 12),

                // PRODUCT GRID
                _buildProductGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== HEADER — sama persis dengan UI lama =====
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Nama Toko', style: AppTextStyles.heading3),
              ),
            ],
          ),

          // KERANJANG BADGE
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(
                  '/cart',
                  extra: {'items': _cartItems, 'qty': _cartQty},
                ),
                icon: FaIcon(
                  FontAwesomeIcons.cartShopping,
                  color: AppColors.primaryLight,
                ),
              ),

              if (_totalItem > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '$_totalItem',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== PRODUCT GRID — sama seperti UI lama =====
  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Produk tidak ditemukan', style: AppTextStyles.caption),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final k = filtered[index];
        return AppProductCard(
          name: k.nama,
          category: k.kategori,
          price: k.harga,
          hargaJual: k.harga,
          foto: k.icon ?? '🛍️',
          onAdd: () => _addToCart(k), // ← buka modal dulu seperti UI lama
          onTap: () {
            context.push('/product-detail', extra: k);
          },
        );
      },
    );
  }

  // ===== MODAL DETAIL PRODUK =====
  void _showCartSheet(KatalogItem item) {
    int qty = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HANDLE
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🛒 Add to Cart', style: AppTextStyles.heading3),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // PRODUCT ROW
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // FOTO / EMOJI
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: _buildImage(item.icon ?? '🛍️'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.nama, style: AppTextStyles.bodyBold),
                          const SizedBox(height: 4),
                          Text(
                            _rupiahFmt.format(item.harga),
                            style: AppTextStyles.price,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // BUTTON ADD TO CART
              GestureDetector(
                onTap: () {
                  for (int i = 0; i < qty; i++) {
                    _addToCart(item);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ $qty item ditambahkan ke keranjang!'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HELPER: tampilkan foto atau emoji =====
  Widget _buildImage(String icon) {
    final isUrl = icon.startsWith('http://') || icon.startsWith('https://');

    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          icon,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Text('🛍️', style: TextStyle(fontSize: 48)),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const SizedBox(
                  height: 80,
                  width: 80,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
        ),
      );
    }

    return Text(icon, style: const TextStyle(fontSize: 48));
  }
}
