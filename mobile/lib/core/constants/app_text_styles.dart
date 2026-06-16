import 'package:flutter/material.dart';
import 'package:kasir_offline/core/constants/app_colors.dart';

class AppTextStyles {
  // Private constructor — sama seperti AppColors
  // tidak perlu dibuat object-nya
  AppTextStyles._();

  // ===== HEADING =====
  // Untuk judul halaman besar
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Untuk judul halaman kecil
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Untuk subjudul
  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ===== BODY =====
  // Untuk teks biasa
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Untuk teks biasa tapi tebal
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ===== CAPTION =====
  // Untuk teks kecil seperti keterangan
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Untuk label kecil seperti kategori
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ===== BUTTON =====
  // Untuk teks di dalam tombol
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  // ===== HARGA =====
  // Untuk tampilan harga produk
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  // ===== HEADER PUTIH =====
  // Untuk teks di atas background biru
  static const TextStyle headerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white60,
  );
}
