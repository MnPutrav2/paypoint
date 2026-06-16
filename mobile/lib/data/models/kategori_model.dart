class KategoriModel {
  final String id;
  final String nama;

  KategoriModel({required this.id, required this.nama});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama};
}
