class TransaksiItem {
  final String id;
  final String produk;
  final int jumlah;
  final int subtotal;
  final int profit;

  TransaksiItem({
    required this.id,
    required this.produk,
    required this.jumlah,
    required this.subtotal,
    required this.profit,
  });

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    return TransaksiItem(
      id: json['id']?.toString() ?? '',
      produk: json['produk']?.toString() ?? '',
      jumlah: json['jumlah'] as int? ?? 0,
      subtotal: json['subtotal'] as int? ?? 0,
      profit: json['profit'] as int? ?? 0,
    );
  }
}

class StatusTransaksi {
  static const int batal = 1;
  static const int selesai = 2;
  static const int diproses = 3;
  static const int sudahBayar = 4;
  static const int belumBayar = 5;
  static const int expired = 6;
  static const int pending = 7;
}

class TransaksiModel {
  final String id;
  final String invoice;
  final String namaCustomer;
  final int total;
  final String status;
  final int statusInt;
  final String createdAt;
  final List<TransaksiItem> items;

  TransaksiModel({
    required this.id,
    required this.invoice,
    required this.namaCustomer,
    required this.total,
    required this.status,
    required this.statusInt,
    required this.createdAt,
    required this.items,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    // ✅ items bisa null dari BE
    final itemList = json['items'] == null
        ? <TransaksiItem>[]
        : (json['items'] as List<dynamic>)
              .map((e) => TransaksiItem.fromJson(e as Map<String, dynamic>))
              .toList();

    return TransaksiModel(
      id: json['id']?.toString() ?? '',
      invoice: json['invoice']?.toString() ?? '',
      namaCustomer: json['nama_customer']?.toString() ?? '-',
      total: json['total'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      statusInt: json['status_int'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      items: itemList,
    );
  }
}

class TransaksiResponse {
  final List<TransaksiModel> items;
  final int total;
  final int pageIndex;
  final int pageSize;

  TransaksiResponse({
    required this.items,
    required this.total,
    required this.pageIndex,
    required this.pageSize,
  });

  factory TransaksiResponse.fromJson(Map<String, dynamic> json) {
    final itemList = (json['result'] as List<dynamic>? ?? [])
        .map((e) => TransaksiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TransaksiResponse(
      items: itemList,
      total:
          json['total'] as int? ??
          itemList.length, // ✅ pakai total dari BE kalau ada
      pageIndex: json['pageIndex'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}
