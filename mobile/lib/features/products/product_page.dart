import 'package:flutter/material.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/local/database_helper.dart';
import 'package:kasir_offline/data/models/product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final db = DatabaseHelper.instance;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    products = await db.getProducts();
    setState(() {});
  }

  // ===== FORM TAMBAH / EDIT PRODUK =====
  void showForm({Product? product}) {
    final nameController = TextEditingController(text: product?.nama ?? '');
    final priceController = TextEditingController(
      text: product?.harga.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          product == null ? 'Tambah Produk' : 'Edit Produk',
          style: AppTextStyles.heading3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // INPUT NAMA — pakai AppTextField ✅
            AppTextField(hint: 'Nama Produk', controller: nameController),

            const SizedBox(height: 12),

            // INPUT HARGA — pakai AppTextField ✅
            AppTextField(
              hint: 'Harga',
              controller: priceController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          // TOMBOL BATAL
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // TOMBOL SIMPAN — pakai AppButton ✅
          AppButton(
            label: 'Simpan',
            isFullWidth: false,
            onTap: () async {
              final name = nameController.text;
              final price = int.tryParse(priceController.text) ?? 0;

              if (name.isEmpty || price <= 0) return;

              //   if (product == null) {
              //     await db.insertProduct(Product(nama: name, harga: price));
              //   } else {
              //     await db.updateProduct(
              //       Product(id: product.id, nama: name, harga: price),
              //     );
              //   }

              Navigator.pop(context);
              loadProducts();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ===== HEADER =====
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Produk', style: AppTextStyles.headerTitle),
        actions: [
          IconButton(
            onPressed: () => showForm(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),

      // ===== LIST PRODUK =====
      body: products.isEmpty
          ? Center(
              child: Text(
                'Belum ada produk\nTambah produk dengan tombol +',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = products[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ICON PRODUK
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // INFO PRODUK
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nama, style: AppTextStyles.bodyBold),
                            const SizedBox(height: 4),
                            Text('Rp ${p.harga}', style: AppTextStyles.price),
                          ],
                        ),
                      ),

                      // TOMBOL EDIT & HAPUS — pakai AppActionButton ✅
                      AppActionButton.edit(onTap: () => showForm(product: p)),

                      const SizedBox(width: 8),

                      AppActionButton.delete(
                        onTap: () async {
                          await db.deleteProduct(p.id);
                          loadProducts();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
