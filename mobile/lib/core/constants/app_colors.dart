import 'package:flutter/material.dart';

class AppColors {
  // ===== PRIVATE CONSTRUCTOR =====
  // Sama seperti AppNavigation._()
  // Tidak bisa dibuat object-nya, cukup akses langsung
  AppColors._();

  // ===== WARNA UTAMA =====
  static const Color primary = Color(0xFF1B4F72);
  // 'static' = bisa diakses tanpa buat object
  // 'const'  = nilai tetap, tidak berubah
  // Cara pakai: AppColors.primary

  static const Color primaryDark = Color(0xFF12273E);
  static const Color primaryLight = Color(0xFF294B71);

  // ===== WARNA BACKGROUND =====
  static const Color background = Color(0xFFF0F4F8);
  static const Color backgroundCard = Colors.white;
  static const Color backgroundInput = Color(0xFFF2F2F2);

  // ===== WARNA TEKS =====
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Colors.grey;
  static const Color textWhite = Colors.white;

  // ===== WARNA STATUS =====
  // dipakai untuk badge stok
  static const Color successBackground = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF16A34A);

  static const Color warningBackground = Color(0xFFFEF9C3);
  static const Color warningText = Color(0xFFCA8A04);

  static const Color dangerBackground = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFDC2626);

  // ===== WARNA AKSI =====
  static const Color editBackground = Color(0xFFE0F0FF);
  static const Color editIcon = Color(0xFF1B4F72);
}
