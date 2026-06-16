import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/app_colors.dart';
import 'package:kasir_offline/core/constants/app_text_styles.dart';

class AppButton extends StatelessWidget {
  // ===== PROPERTIES =====
  // Semua hal yang bisa dikustomisasi dari luar
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor; // ? = opsional, boleh tidak diisi
  final Color? textColor; // ? = opsional
  final bool isFullWidth; // default true

  const AppButton({
    super.key,
    required this.label, // wajib diisi
    required this.onTap, // wajib diisi
    this.backgroundColor, // opsional
    this.textColor, // opsional
    this.isFullWidth = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          // pakai warna custom kalau ada, kalau tidak pakai primary
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            // pakai warna custom kalau ada
            color: textColor ?? AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}
