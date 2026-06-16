import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';

class ProductDetailPage extends StatefulWidget {
  final KatalogItem item;

  const ProductDetailPage({super.key, required this.item});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // State cart lokal di halaman ini
  final Map<String, KatalogItem> _cartItems = {};
  final Map<String, int> _cartQty = {};

  int get _totalCartQty => _cartQty.values.fold(0, (sum, qty) => sum + qty);

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  void _addToCart(KatalogItem item, int qty) {
    setState(() {
      _cartItems[item.id] = item;
      _cartQty[item.id] = (_cartQty[item.id] ?? 0) + qty;
    });
  }

  Widget _buildIcon(String icon) {
    final isUrl = icon.startsWith('http://') || icon.startsWith('https://');
    if (isUrl) {
      return Image.network(
        icon,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Text('🛍️', style: TextStyle(fontSize: 80))),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
      );
    }
    return Center(child: Text(icon, style: const TextStyle(fontSize: 100)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.backgroundCard,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Tombol cart di kanan atas
                actions: [
                  if (_totalCartQty > 0)
                    GestureDetector(
                      onTap: () => context.push(
                        '/cart',
                        extra: {'items': _cartItems, 'qty': _cartQty},
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_totalCartQty',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.backgroundCard,
                        ],
                      ),
                    ),
                    child: _buildIcon(widget.item.icon ?? '🛍️'),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.item.kategori,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(widget.item.nama, style: AppTextStyles.heading2),
                          const SizedBox(height: 12),
                          Text(
                            _formatRupiah(widget.item.harga),
                            style: AppTextStyles.price.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 20),
                          Container(height: 1, color: const Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),
                          Text(
                            'Deskripsi Produk',
                            style: AppTextStyles.bodyBold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Produk berkualitas tinggi dengan performa terbaik. '
                            'Dirancang untuk memenuhi kebutuhan sehari-hari '
                            'dengan kualitas terjamin.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ADD TO CART
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppProductModal.show(
                        context,
                        widget.item,
                        isCart: true,
                        onConfirm: (item, qty) {
                          // ✅ Simpan ke state lokal
                          _addToCart(item, qty);

                          // ✅ Navigasi ke cart
                          context.push(
                            '/cart',
                            extra: {'items': _cartItems, 'qty': _cartQty},
                          );
                        },
                      ),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add to Cart',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // BUY NOW
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => AppProductModal.show(
                        context,
                        widget.item,
                        isCart: false,
                        onConfirm: (item, qty) {
                          // Buy now: langsung ke cart tanpa simpan state
                          context.push(
                            '/cart',
                            extra: {
                              'items': {item.id: item},
                              'qty': {item.id: qty},
                            },
                          );
                        },
                      ),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buy Now',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
