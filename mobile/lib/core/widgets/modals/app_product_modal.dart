import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';

class AppProductModal {
  AppProductModal._();

  static void show(
    BuildContext context,
    KatalogItem item, {
    required bool isCart,
    required Function(KatalogItem item, int qty) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ModalContent(item: item, isCart: isCart, onConfirm: onConfirm),
    );
  }
}

class _ModalContent extends StatefulWidget {
  final KatalogItem item;
  final bool isCart;
  final Function(KatalogItem item, int qty) onConfirm;

  const _ModalContent({
    required this.item,
    required this.isCart,
    required this.onConfirm,
  });

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  int _qty = 1;

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  int get _totalHarga => widget.item.harga * _qty;

  Widget _buildIcon(String icon) {
    final isUrl = icon.startsWith('http://') || icon.startsWith('https://');
    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          icon,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Text('🛍️', style: TextStyle(fontSize: 36)),
        ),
      );
    }
    return Text(icon, style: const TextStyle(fontSize: 44));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
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
              Text(
                widget.isCart ? '🛒 Add to Cart' : '⚡ Buy Now',
                style: AppTextStyles.heading3,
              ),
              GestureDetector(
                onTap: () => context.pop(),
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
                _buildIcon(widget.item.icon ?? '🛍️'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.nama, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(widget.item.harga),
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // JUMLAH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah', style: AppTextStyles.label),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _qty > 1 ? () => setState(() => _qty--) : null,
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.remove_rounded,
                          size: 18,
                          color: _qty > 1
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 46,
                      child: Text(
                        '$_qty',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _qty++),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TOTAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.caption),
                Text(
                  _formatRupiah(_totalHarga),
                  style: AppTextStyles.price.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BUTTON CONFIRM
          GestureDetector(
            onTap: () {
              context.pop();
              widget.onConfirm(widget.item, _qty);
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: widget.isCart
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                color: widget.isCart ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(16),
                border: widget.isCart
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
                boxShadow: widget.isCart
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
                  Icon(
                    widget.isCart
                        ? Icons.shopping_cart_rounded
                        : Icons.bolt_rounded,
                    color: widget.isCart ? AppColors.primary : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isCart ? 'Add to Cart' : 'Buy Now',
                    style: AppTextStyles.label.copyWith(
                      color: widget.isCart ? AppColors.primary : Colors.white,
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
    );
  }
}
