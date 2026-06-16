import 'package:intl/intl.dart';

class DummyProducts {
  DummyProducts._();

  static String formatHarga(int harga) {
    final formatter = NumberFormat('#,###', 'id_ID');
    //                              ↑         ↑
    //                         format      locale Indonesia
    //                         #,### = pisah ribuan pakai titik
    return 'Rp ${formatter.format(harga)}';
  }

  // Ganti const → final ✅
  static final List<Map<String, dynamic>> products = [
    {
      'name': 'Iphone 14 Pro',
      'category': 'HP',
      'price': formatHarga(15000000),
      'priceValue': 15000000,
      'icon': '📱',
      'stock': 12,
      'stockPerColor': {'Hitam': 3, 'Putih': 3, 'Biru': 3, 'Merah': 3},
    },
    {
      'name': 'Galaxy Watch 5',
      'category': 'Aksesoris',
      'price': formatHarga(3000000),
      'priceValue': 3000000,
      'icon': '⌚',
      'stock': 3,
      'stockPerColor': {'Hitam': 1, 'Putih': 1, 'Biru': 1, 'Merah': 0},
    },
    {
      'name': 'Macbook Pro M2',
      'category': 'Laptop',
      'price': formatHarga(25000000),
      'priceValue': 25000000,
      'icon': '💻',
      'stock': 8,
      'stockPerColor': {'Hitam': 2, 'Putih': 2, 'Biru': 2, 'Merah': 2},
    },
    {
      'name': 'AirPods Pro',
      'category': 'Aksesoris',
      'price': formatHarga(4000000),
      'priceValue': 4000000,
      'icon': '🎧',
      'stock': 1,
      'stockPerColor': {'Hitam': 1, 'Putih': 0, 'Biru': 0, 'Merah': 0},
    },
    {
      'name': 'Samsung S23',
      'category': 'HP',
      'price': formatHarga(12000000),
      'priceValue': 12000000,
      'icon': '📱',
      'stock': 15,
      'stockPerColor': {'Hitam': 4, 'Putih': 4, 'Biru': 4, 'Merah': 3},
    },
    {
      'name': 'Charger 65W',
      'category': 'Charger',
      'price': formatHarga(500000),
      'priceValue': 500000,
      'icon': '🔌',
      'stock': 2,
      'stockPerColor': {'Hitam': 1, 'Putih': 1, 'Biru': 0, 'Merah': 0},
    },
  ];
}
