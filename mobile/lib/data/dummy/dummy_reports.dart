import 'package:flutter/material.dart';
import 'package:kasir_offline/data/dummy/dummy_products.dart';
import 'package:kasir_offline/data/dummy/dummy_transactions.dart';

class DummyReports {
  DummyReports._();

  static List<Map<String, dynamic>> get summaryCards => [
    {
      'label': 'Total Transaksi',
      'value': '${DummyTransactions.totalTransaksi}',
      'percent': '+4,8%',
      'isUp': true,
      'icon': Icons.receipt_long_rounded, // ← tambah
      'color': const Color(0xFF3B82F6), // ← tambah
    },
    {
      'label': 'Total Omzet',
      'value': _formatRupiah(DummyTransactions.totalOmzet),
      'percent': '+2,5%',
      'isUp': true,
      'icon': Icons.shopping_cart_rounded, // ← tambah
      'color': const Color(0xFF1B4F72), // ← tambah
    },
    {
      'label': 'Produk Terjual',
      'value': '${DummyTransactions.totalProdukTerjual}',
      'percent': '-1,8%',
      'isUp': false,
      'icon': Icons.inventory_2_rounded, // ← tambah
      'color': const Color(0xFF8B5CF6), // ← tambah
    },
    {
      'label': 'Rata-rata/Hari',
      'value': _formatRupiah(DummyTransactions.rataRataPerHari),
      'percent': '+2,0%',
      'isUp': true,
      'icon': Icons.trending_up_rounded, // ← tambah
      'color': const Color(0xFF10B981), // ← tambah
    },
  ];

  static List<Map<String, dynamic>> get topProducts {
    final sorted = List<Map<String, dynamic>>.from(DummyProducts.products)
      ..sort((a, b) => (b['stock'] as int).compareTo(a['stock'] as int));
    return sorted.take(5).toList();
  }

  static String _formatRupiah(int value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp $value';
  }
}
