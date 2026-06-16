import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/index.dart';
import 'package:kasir_offline/core/utils/rupiah_extension.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AppBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  // ===== FACTORY CONSTRUCTOR =====
  // Sama seperti AppActionButton — shortcut dengan preset

  // Badge Stok Aman — hijau
  factory AppBadge.success({required String label}) {
    return AppBadge(
      label: label,
      backgroundColor: AppColors.successBackground,
      textColor: AppColors.successText,
    );
  }

  // Badge Stok Hampir Habis — kuning
  factory AppBadge.warning({required String label}) {
    return AppBadge(
      label: label,
      backgroundColor: AppColors.warningBackground,
      textColor: AppColors.warningText,
    );
  }

  // Badge Stok Habis — merah
  factory AppBadge.danger({required String label}) {
    return AppBadge(
      label: label,
      backgroundColor: AppColors.dangerBackground,
      textColor: AppColors.dangerText,
    );
  }

  // ===== HELPER — otomatis pilih warna berdasarkan stok =====
  factory AppBadge.stock({required int stock}) {
    if (stock == 0) {
      return AppBadge.danger(label: 'Habis');
    } else if (stock <= 3) {
      return AppBadge.warning(label: 'Stok: $stock');
    } else {
      return AppBadge.success(label: 'Stok: $stock');
    }
  }

  factory AppBadge.harga({required int harga}) {
    if (harga == 0) {
      return AppBadge.danger(label: 'Belum Diatur');
    } else {
      return AppBadge.success(label: harga.toRupiah());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
