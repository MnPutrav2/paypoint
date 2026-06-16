class Product {
  final String id;
  final String nama;
  final String? detail;
  final int harga;
  final String? foto;

  final String? katalogId;
  final int? hargaJual;
  final bool? katalog;

  final int terjual;
  final int stok;

  final ProductCategory kategori;

  const Product({
    required this.id,
    required this.nama,
    this.detail,
    required this.harga,

    this.katalogId,
    required this.katalog,
    required this.hargaJual,

    this.foto,
    required this.terjual,
    required this.stok,
    required this.kategori,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      detail: json['detail']?.toString(),
      harga: num.tryParse(json['harga'].toString())?.toInt() ?? 0,

      katalogId: json['katalogId']?.toString() ?? '',
      hargaJual: num.tryParse(json['hargaJual'].toString())?.toInt() ?? 0,
      katalog: json['katalog'] ?? false,

      foto: json['foto']?.toString(),

      terjual: (json['terjual'] as num?)?.toInt() ?? 0,

      stok: (json['stok'] as num?)?.toInt() ?? 0,

      kategori: ProductCategory.fromJson(
        json['kategori'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'detail': detail,
    'harga': harga,
    'hargaJual': hargaJual,
    'katalogId': katalogId,
    'katalog': katalog,
    'foto': foto,
    'terjual': terjual,
    'stok': stok,
    'kategori': kategori.toJson(),
  };

  Product copyWith({
    String? nama,
    String? detail,
    int? harga,

    String? katalogId,
    int? hargaJual,
    bool? katalog,

    int? stok,
    String? foto,
    ProductCategory? kategori,
  }) {
    return Product(
      id: id,
      nama: nama ?? this.nama,
      detail: detail ?? this.detail,
      harga: harga ?? this.harga,

      katalogId: katalogId ?? this.katalogId,
      katalog: katalog ?? this.katalog,
      hargaJual: hargaJual ?? this.hargaJual,

      stok: stok ?? this.stok,
      foto: foto ?? this.foto,
      kategori: kategori ?? this.kategori,
      terjual: terjual,
    );
  }
}

class ProductCategory {
  final String id;
  final String nama;
  final String? deskripsi;

  const ProductCategory({required this.id, required this.nama, this.deskripsi});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'deskripsi': deskripsi,
  };
}
