import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';

class CartPage extends StatefulWidget {
  final Map<String, KatalogItem> items;
  final Map<String, int> qty;

  const CartPage({super.key, required this.items, required this.qty});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> get cartItems {
    return widget.items.entries.map((e) {
      return {'item': e.value, 'qty': widget.qty[e.key] ?? 1};
    }).toList();
  }

  int get totalHarga {
    return cartItems.fold(0, (sum, e) {
      final item = e['item'] as KatalogItem;
      final qty = e['qty'] as int;
      return sum + (item.harga * qty);
    });
  }

  void _removeItem(String id) {
    setState(() {
      widget.items.remove(id);
      widget.qty.remove(id);
    });
  }

  void _updateQty(String id, int delta) {
    setState(() {
      final current = widget.qty[id] ?? 1;
      final newQty = current + delta;
      if (newQty <= 0) {
        widget.items.remove(id);
        widget.qty.remove(id);
      } else {
        widget.qty[id] = newQty;
      }
    });
  }

  void _clearCart() {
    setState(() {
      widget.items.clear();
      widget.qty.clear();
    });
  }

  // ✅ Checkout: kirim data ke PaymentPage
  // void _checkout() {
  //   final nama = _namaController.text.trim().isEmpty
  //       ? 'Pembeli'
  //       : _namaController.text.trim();

  //   final snapshotItems = cartItems.map((e) {
  //     final item = e['item'] as KatalogItem;
  //     final qty = e['qty'] as int;
  //     return {
  //       'id': item.id,
  //       'name': item.nama,
  //       'icon': item.icon ?? '🛍️',
  //       'qty': qty,
  //       'harga': item.harga,
  //     };
  //   }).toList();

  //   // Tampilkan pilihan metode bayar
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (ctx) => _MetodeBayarSheet(
  //       totalHarga: totalHarga,
  //       onPilih: (metode) {
  //         Navigator.pop(ctx);
  //         context.push(
  //           '/payment',
  //           extra: {
  //             'namaPembeli': nama,
  //             'items': snapshotItems,
  //             'totalHarga': totalHarga,
  //             'metode': metode,
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }
  void _checkout() {
    final nama = _namaController.text.trim().isEmpty
        ? 'Pembeli'
        : _namaController.text.trim();

    // ✅ Ambil semua data DULU sebelum _clearCart()
    final total = totalHarga; // simpan dulu ke variable
    final snapshotItems = cartItems.map((e) {
      final item = e['item'] as KatalogItem;
      final qty = e['qty'] as int;
      return {
        'id': item.id,
        'name': item.nama,
        'icon': item.icon ?? '🛍️',
        'qty': qty,
        'harga': item.harga,
      };
    }).toList();

    // ✅ Baru clear cart setelah data diambil
    _clearCart();

    context.push(
      '/payment',
      extra: {
        'namaPembeli': nama,
        'items': snapshotItems,
        'totalHarga': total, // ✅ pakai variable, bukan totalHarga langsung
        'metode': 'tunai',
      },
    );
  }

  final TextEditingController _namaController = TextEditingController();

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 140),
                  child: Column(
                    children: [
                      _buildNamaInput(),
                      const SizedBox(height: 12),
                      _buildCartItems(),
                      const SizedBox(height: 10),
                      if (cartItems.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildSummary(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundCard,
      elevation: 0,
      pinned: true,
      leading: GestureDetector(
        onTap: () => context.go('/home'),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Keranjang', style: AppTextStyles.bodyBold),
          Text(
            '${cartItems.length} produk dipilih',
            style: AppTextStyles.caption,
          ),
        ],
      ),
      actions: [
        if (cartItems.isNotEmpty)
          GestureDetector(
            onTap: _clearCart,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hapus Semua',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildNamaInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👤 Informasi Pembeli',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Text('✏️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama pembeli...',
                      hintStyle: AppTextStyles.caption,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    if (cartItems.isEmpty) return _buildEmptyState();

    return Column(
      children: cartItems.map((data) {
        final item = data['item'] as KatalogItem;
        final qty = data['qty'] as int;
        return AppCartItemCard(
          item: {
            'name': item.nama,
            'price': item.harga,
            'icon': item.icon ?? '🛍️',
            'qty': qty,
          },
          onDelete: () => _removeItem(item.id),
          onIncrement: () => _updateQty(item.id, 1),
          onDecrement: () => _updateQty(item.id, -1),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 14),
          Text('Keranjang Kosong', style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text(
            'Belum ada produk yang ditambahkan',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Belanja', style: AppTextStyles.bodyBold),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${cartItems.length} produk)',
                style: AppTextStyles.caption,
              ),
              Text(
                _formatRupiah(totalHarga),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon', style: AppTextStyles.caption),
              Text(
                '- Rp 0',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bodyBold),
              Text(
                _formatRupiah(totalHarga),
                style: AppTextStyles.price.copyWith(fontSize: 17),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isEmpty = cartItems.isEmpty;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran', style: AppTextStyles.caption),
                Text(
                  _formatRupiah(totalHarga),
                  style: AppTextStyles.price.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              // ✅ Panggil _checkout() bukan showDialog inline
              onTap: isEmpty ? null : _checkout,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isEmpty
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                  color: isEmpty
                      ? AppColors.textSecondary.withOpacity(0.3)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isEmpty
                      ? null
                      : [
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
                    const Text('⚡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Checkout Sekarang',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetodeBayarSheet extends StatelessWidget {
  final int totalHarga;
  final Function(String metode) onPilih;

  const _MetodeBayarSheet({required this.totalHarga, required this.onPilih});

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Pilih Metode Bayar', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            'Total: ${_formatRupiah(totalHarga)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPilih('tunai'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF16A34A).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('💵', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          'Tunai',
                          style: AppTextStyles.label.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPilih('transfer'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('🏦', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          'Transfer',
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
            ],
          ),
        ],
      ),
    );
  }
}
