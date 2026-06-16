class DummyOrders {
  DummyOrders._();

  // ===== LIST PESANAN DI MEMORY =====
  static final List<Map<String, dynamic>> orders = [];

  // ===== TAMBAH PESANAN DARI CART =====
  static void addOrder({
    required String namaPembeli,
    required List<Map<String, dynamic>> items,
    required int totalHarga,
  }) {
    final String id = '#ORD-${(orders.length + 1).toString().padLeft(3, '0')}';
    final String waktu = _formatWaktu();

    orders.add({
      'id': id,
      'namaPembeli': namaPembeli,
      'items': List.from(items), // copy dari cart
      'totalHarga': totalHarga,
      'waktu': waktu,
      'isPaid': false,
      'metodeBayar': null,
    });
  }

  // ===== TANDAI SUDAH BAYAR =====
  static void markAsPaid(String id, String metode) {
    final int index = orders.indexWhere((o) => o['id'] == id);
    if (index >= 0) {
      orders[index]['isPaid'] = true;
      orders[index]['metodeBayar'] = metode;
    }
  }

  // ===== FILTER =====
  static List<Map<String, dynamic>> get belumDibayar =>
      orders.where((o) => o['isPaid'] == false).toList();

  static List<Map<String, dynamic>> get sudahDibayar =>
      orders.where((o) => o['isPaid'] == true).toList();

  // ===== FORMAT WAKTU =====
  static String _formatWaktu() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m · Hari ini';
  }
}
