import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/app_colors.dart';
import 'package:kasir_offline/core/constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  // ===== PROPERTIES =====
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType; // jenis keyboard (email, number, dll)
  final String? Function(String?)? validator; // untuk validasi form

  const AppTextField({
    super.key,
    required this.hint, // wajib
    this.isPassword = false, // default false
    this.controller, // opsional
    this.keyboardType, // opsional
    this.validator, // opsional
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.backgroundInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        // border biru saat diklik ✅
      ),
    );
  }
}
