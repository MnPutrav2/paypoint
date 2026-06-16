import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/index.dart';

class AppActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final double size; // ukuran tombol, default 28
  final double iconSize; // ukuran icon, default 14

  const AppActionButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.size = 28, // default 28
    this.iconSize = 14, // default 14
  });

  // ===== FACTORY CONSTRUCTOR =====
  // Cara cepat buat tombol yang sudah ada warnanya
  // Tidak perlu isi warna manual setiap saat

  // Tombol Edit — biru
  factory AppActionButton.edit({required VoidCallback onTap}) {
    return AppActionButton(
      icon: Icons.edit_rounded,
      backgroundColor: AppColors.editBackground,
      iconColor: AppColors.editIcon,
      onTap: onTap,
    );
  }

  // Tombol Hapus — merah
  factory AppActionButton.delete({required VoidCallback onTap}) {
    return AppActionButton(
      icon: Icons.delete_rounded,
      backgroundColor: AppColors.dangerBackground,
      iconColor: AppColors.dangerText,
      onTap: onTap,
    );
  }

  // Tombol Tambah — hijau
  factory AppActionButton.add({required VoidCallback onTap}) {
    return AppActionButton(
      icon: Icons.add_rounded,
      backgroundColor: AppColors.successBackground,
      iconColor: AppColors.successText,
      onTap: onTap,
    );
  }

  // Tombol Kurangi — merah
  factory AppActionButton.minus({required VoidCallback onTap}) {
    return AppActionButton(
      icon: Icons.remove_rounded,
      backgroundColor: AppColors.dangerBackground,
      iconColor: AppColors.dangerText,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
