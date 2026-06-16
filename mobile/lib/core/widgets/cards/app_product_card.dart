import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/index.dart';
import 'package:kasir_offline/core/utils/rupiah_extension.dart';
import 'package:kasir_offline/core/widgets/buttons/index.dart';
import 'package:kasir_offline/core/widgets/badges/index.dart';

class AppProductCard extends StatelessWidget {
  final String name;
  final String category;
  final int price;
  final int? hargaJual;
  final String foto;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onMinus;
  final VoidCallback? onDelete;
  final VoidCallback? onTap; // ← tambah parameter ini
  final bool showStock;

  const AppProductCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.hargaJual,
    required this.foto,
    this.onAdd,
    this.onEdit,
    this.onMinus,
    this.onDelete,
    this.onTap,
    this.showStock = false,
  });

  @override
  Widget build(BuildContext context) {
    // ===== MODE STOCK — Row, tidak butuh tinggi pasti =====
    if (showStock) {
      return GestureDetector(
        // ← wrap di sini
        onTap: onTap, // ← pakai parameter onTap
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: foto.isNotEmpty
                    ? Image.network(
                        foto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.inventory_2_outlined,
                            size: 24,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ← penting!
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(category, style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(price.toRupiah(), style: AppTextStyles.price),
                  ],
                ),
              ),

              // KANAN
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, // ← penting!
                children: [
                  AppBadge.harga(harga: hargaJual!),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppActionButton.edit(onTap: onEdit ?? () {}),
                      const SizedBox(width: 6),
                      AppActionButton.delete(onTap: onDelete ?? () {}),
                      //   AppActionButton.minus(onTap: onMinus ?? () {}),
                      //   const SizedBox(width: 6),
                      //   AppActionButton.add(onTap: onAdd ?? () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ===== MODE KASIR — Column untuk GridView =====
    return GestureDetector(
      onTap: onTap, // ← tambah ini!
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                width: double.infinity,
                padding: EdgeInsets.all(4),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: foto.isNotEmpty
                        ? Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.inventory_2_outlined,
                                size: 24,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            size: 24,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price.toRupiah(), style: AppTextStyles.price),
                      AppActionButton.add(onTap: onAdd ?? () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildImage(String icon) {
  // Cek apakah icon adalah URL
  final isUrl = icon.startsWith('http://') || icon.startsWith('https://');

  if (isUrl) {
    return Image.network(
      icon,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('🛍️', style: TextStyle(fontSize: 40))),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  // Fallback: emoji
  return Center(child: Text(icon, style: const TextStyle(fontSize: 40)));
}
