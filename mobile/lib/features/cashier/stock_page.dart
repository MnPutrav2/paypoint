import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/core/utils/debounce.dart';
import 'package:kasir_offline/data/models/product.dart';
import 'package:kasir_offline/features/products/product_add_page.dart';
import 'package:kasir_offline/features/products/product_edit_page.dart';
import 'package:kasir_offline/features/providers/product_provider.dart';
// import 'package:go_router/go_router.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  final _debounce = Debounce();

  //   final _categories =
  //       _selectedCategory == 0 ||
  //       p.kategori.nama == _categories[_selectedCategory];
  //   int _selectedCategory = 0;
  // int _selectedIndex = 0;

  // ===== FILTER =====
  //   List<Product> _filterProducts(List<Product> products) {
  //     return products.where((p) {
  //       final matchSearch = p.nama.toLowerCase().contains(
  //         _searchQuery.toLowerCase(),
  //       );

  //       final matchCategory =
  //           _selectedCategory == 0 ||
  //           p.kategori.nama == _categories[_selectedCategory];

  //       return matchSearch && matchCategory;
  //     }).toList();
  //   }

  // ===== STATS =====
  int totalProducts(List<Product> products) {
    return products.length;
  }

  // int lowStock(List<Product> products) {
  //   return products.where((p) => (p.stok ?? 0) <= 3).length;
  // }

  // int outOfStock(List<Product> products) {
  //   return products.where((p) => (p.stok ?? 0) == 0).length;
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(produkListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          final products = state.products;

          return Column(
            children: [
              _buildHeader(products),

              // SEARCH ✅
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AppSearchBar(
                  hint: 'Cari Produk...',
                  onChanged: (value) => {
                    _debounce(() {
                      ref.read(produkListProvider.notifier).setSearch(value);
                    }),
                  },
                ),
              ),

              //   // CATEGORIES ✅
              //   AppCategoryTabs(
              //     categories: _categories,
              //     selectedIndex: _selectedCategory,
              //     onTap: (index) => setState(() => _selectedCategory = index),
              //   ),

              // SECTION LABEL
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('DAFTAR PRODUK', style: AppTextStyles.label),
                ),
              ),

              // PRODUCT LIST
              Expanded(child: _buildProductList(products)),
            ],
          );
        },
      ),
    );

    //   // BOTTOM NAV ✅
    //   bottomNavigationBar: AppBottomNav(
    //     selectedIndex: _selectedIndex,
    //     onTap: (index) => setState(() => _selectedIndex = index),
    //   ),

    //   // FAB HOME ✅
    //   floatingActionButton: AppFabHome(
    //     onTap: () => context.go('/home'),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  }

  // ===== HEADER =====
  Widget _buildHeader(List<Product> products) {
    int total = totalProducts(products);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JUDUL + TOMBOL TAMBAH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('List Produk', style: AppTextStyles.headerTitle),
                  const SizedBox(height: 2),
                  Text('KAVI - Kasir', style: AppTextStyles.headerSubtitle),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TambahProdukPage()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // STATS ROW
          Row(
            children: [
              _buildStatCard('Total Produk', '$total', AppColors.textWhite),
              //   const SizedBox(width: 10),
              //   _buildStatCard(
              //     'Stok Rendah',
              //     '$_lowStock',
              //     const Color(0xFFFCD34D),
              //   ),
              //   const SizedBox(width: 10),
              //   _buildStatCard('Habis', '$_outOfStock', const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }

  // ===== STAT CARD =====
  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.label.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Produk?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Produk "${product.nama}" akan dihapus permanen.\nTindakan ini tidak bisa dibatalkan.',
          style: const TextStyle(color: Colors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(produkListProvider.notifier)
        .deleteProduct(product.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              success
                  ? '${product.nama} berhasil dihapus'
                  : 'Gagal menghapus produk',
            ),
          ],
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== PRODUCT LIST =====
  Widget _buildProductList(List<Product> products) {
    // final filtered = _filterProducts(products);

    // if (filtered.isEmpty) {
    //   return Center(
    //     child: Text('Produk tidak ditemukan', style: AppTextStyles.caption),
    //   );
    // }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];

        return AppProductCard(
          name: product.nama,
          category: product.kategori.nama,
          price: product.harga,
          hargaJual: product.hargaJual,
          foto: product.foto ?? '',
          showStock: true,

          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProdukPage(product: product),
              ),
            );
          },
          onDelete: () => _confirmDelete(context, product),

          onAdd: () {
            // panggil API tambah stok
          },

          onMinus: () {
            // panggil API kurangi stok
          },
        );
      },
    );
  }
}
