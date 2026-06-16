class DummyCart {
  DummyCart._();

  // ===== LIST DI MEMORY =====
  static final List<Map<String, dynamic>> items = [];

  // ===== TAMBAH ITEM =====
  static void addItem({
    required Map<String, dynamic> product,
    required int qty,
    required String color,
  }) {
    // Cek apakah produk + warna sudah ada
    final int index = items.indexWhere((e) =>
        e['name'] == product['name'] && e['color'] == color);

    if (index >= 0) {
      // Sudah ada → tambah qty saja
      items[index]['qty'] += qty;
    } else {
      // Belum ada → tambah item baru
      items.add({
        'name'       : product['name'],
        'price'      : product['price'],
        'priceValue' : product['priceValue'],
        'icon'       : product['icon'],
        'category'   : product['category'],
        'color'      : color,
        'qty'        : qty,
      });
    }
  }

  // ===== HAPUS ITEM =====
  static void removeItem(int index) {
    items.removeAt(index);
  }

  // ===== UPDATE QTY =====
  static void updateQty(int index, int qty) {
    if (qty <= 0) {
      removeItem(index);
    } else {
      items[index]['qty'] = qty;
    }
  }

  // ===== TOTAL HARGA =====
  static int get totalHarga => items.fold(
      0, (sum, e) => sum + (e['priceValue'] as int) * (e['qty'] as int));

  // ===== TOTAL ITEM =====
  static int get totalItem =>
      items.fold(0, (sum, e) => sum + (e['qty'] as int));

  // ===== KOSONGKAN CART =====
  static void clear() => items.clear();
}