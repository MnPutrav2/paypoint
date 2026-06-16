import 'package:flutter/material.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:intl/intl.dart';

class AppCartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const AppCartItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item['qty'] as int? ?? 1;
    final price = item['price'] as int? ?? 0;
    final totalPrice = price * qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // ICON
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildIcon(item['icon'] as String? ?? '🛍️'),
            ),
          ),
          const SizedBox(width: 10),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String? ?? '',
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${NumberFormat('#,###', 'id_ID').format(price)} / item',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                // QTY EDITOR
                Row(
                  children: [
                    // Tombol kurang
                    GestureDetector(
                      onTap: onDecrement,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: qty <= 1
                              ? const Color(0xFFFEE2E2)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: qty <= 1
                                ? const Color(0xFFEF4444).withOpacity(0.3)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Icon(
                          qty <= 1
                              ? Icons.delete_outline_rounded
                              : Icons.remove_rounded,
                          size: 14,
                          color: qty <= 1
                              ? const Color(0xFFEF4444)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Angka qty
                    Container(
                      constraints: const BoxConstraints(minWidth: 36),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$qty',
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Tombol tambah
                    GestureDetector(
                      onTap: onIncrement,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TOTAL HARGA + HAPUS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(totalPrice)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildIcon(String icon) {
  final isUrl = icon.startsWith('http://') || icon.startsWith('https://');

  if (isUrl) {
    return Image.network(
      icon,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Text('🛍️', style: TextStyle(fontSize: 26))),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }

  return Center(child: Text(icon, style: const TextStyle(fontSize: 26)));
}
