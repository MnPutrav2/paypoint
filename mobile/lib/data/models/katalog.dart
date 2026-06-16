class KatalogResponse {
  final String id;
  final int hargaKatalog;

  const KatalogResponse({required this.id, required this.hargaKatalog});

  factory KatalogResponse.fromJson(Map<String, dynamic> json) {
    return KatalogResponse(id: json['id'], hargaKatalog: json['harga_katalog']);
  }
}
