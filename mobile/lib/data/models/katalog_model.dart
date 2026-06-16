class KatalogItem {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  // final int stok;
  final String? icon;

  const KatalogItem({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    // required this.stok,
    this.icon,
  });

  factory KatalogItem.fromJson(Map<String, dynamic> json) {
    final produk = json['produk'] as Map<String, dynamic>;
    final kategori = produk['kategori'] as Map<String, dynamic>?;

    return KatalogItem(
      id: json['id'] as String,
      nama: produk['nama'] as String,
      kategori: kategori?['nama'] as String? ?? '-',
      harga: json['harga_katalog'] as int, // ← pakai harga_katalog, bukan harga
      // stok: produk['terjual'] as int? ?? 0,
      icon: produk['foto'] as String?,
    );
  }
}
