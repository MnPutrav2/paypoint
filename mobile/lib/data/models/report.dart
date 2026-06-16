class ReportModel {
  final int saldo;
  final int totalOmzet;
  final int profitHariIni;
  final int totalProfit;
  final int itemTerjual;
  final int transaksiBelumSelesai;
  final List<GrafikItem> grafikOmzet;
  final List<GrafikItem> grafikItemTerlaris;
  final PrediksiOmzet prediksiOmzet;
  final List<String> marketBasket;

  const ReportModel({
    this.saldo = 0,
    this.totalOmzet = 0,
    this.profitHariIni = 0,
    this.totalProfit = 0,
    this.itemTerjual = 0,
    this.transaksiBelumSelesai = 0,
    this.grafikOmzet = const [],
    this.grafikItemTerlaris = const [],
    this.prediksiOmzet = const PrediksiOmzet(),
    this.marketBasket = const [],
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      saldo: json['saldo'] ?? 0,
      totalOmzet: json['total_omzet'] ?? 0,
      profitHariIni: json['profit_hari_ini'] ?? 0,
      totalProfit: json['total_profit'] ?? 0,
      itemTerjual: json['item_terjual'] ?? 0,
      transaksiBelumSelesai: json['transaksi_belum_selesai'] ?? 0,
      grafikOmzet: (json['grafik_omzet'] as List? ?? [])
          .map((e) => GrafikItem.fromJson(e))
          .toList(),
      grafikItemTerlaris: (json['grafik_item_terlaris'] as List? ?? [])
          .map((e) => GrafikItem.fromJson(e))
          .toList(),
      prediksiOmzet: json['prediksi_omzet'] != null
          ? PrediksiOmzet.fromJson(json['prediksi_omzet'])
          : const PrediksiOmzet(),
      marketBasket: (json['market_basket'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class GrafikItem {
  final String label;
  final int value;

  const GrafikItem({this.label = '', this.value = 0});

  factory GrafikItem.fromJson(Map<String, dynamic> json) {
    return GrafikItem(
      label: json['label'] ?? '',
      value: int.tryParse(json['value'].toString()) ?? 0,
    );
  }
}

class PrediksiOmzet {
  final String bulanPrediksi;
  final int nilaiPrediksi;
  final int batasAtas;
  final int batasBawah;
  final String tren;
  final double akurasi;
  final bool cukupData;
  final List<HistorisOmzet> dataHistoris;

  const PrediksiOmzet({
    this.bulanPrediksi = '',
    this.nilaiPrediksi = 0,
    this.batasAtas = 0,
    this.batasBawah = 0,
    this.tren = '',
    this.akurasi = 0,
    this.cukupData = false,
    this.dataHistoris = const [],
  });

  factory PrediksiOmzet.fromJson(Map<String, dynamic> json) {
    return PrediksiOmzet(
      bulanPrediksi: json['bulan_prediksi'] ?? '',
      nilaiPrediksi: (json['nilai_prediksi'] as num?)?.toInt() ?? 0,
      batasAtas: (json['batas_atas'] as num?)?.toInt() ?? 0,
      batasBawah: (json['batas_bawah'] as num?)?.toInt() ?? 0,
      tren: json['tren'] ?? '',
      akurasi: (json['akurasi'] as num?)?.toDouble() ?? 0,
      cukupData: json['cukup_data'] ?? false,
      dataHistoris: (json['data_historis'] as List? ?? [])
          .map((e) => HistorisOmzet.fromJson(e))
          .toList(),
    );
  }
}

class HistorisOmzet {
  final String bulan;
  final int omzet;
  final int indeks;

  const HistorisOmzet({this.bulan = '', this.omzet = 0, this.indeks = 0});

  factory HistorisOmzet.fromJson(Map<String, dynamic> json) {
    return HistorisOmzet(
      bulan: json['bulan'] ?? '',
      omzet: (json['omzet'] as num?)?.toInt() ?? 0,
      indeks: json['indeks'] ?? 0,
    );
  }
}
