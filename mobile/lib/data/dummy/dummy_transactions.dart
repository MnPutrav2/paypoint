class DummyTransactions {
  DummyTransactions._();

  // ===== DATA TRANSAKSI PER HARI =====
  static final List<Map<String, dynamic>> weekly = [
    {'day': 'Min', 'transactions': 12, 'omzet': 4500000},
    {'day': 'Sen', 'transactions': 18, 'omzet': 6200000},
    {'day': 'Sel', 'transactions': 15, 'omzet': 5800000},
    {'day': 'Rab', 'transactions': 22, 'omzet': 7100000},
    {'day': 'Kam', 'transactions': 28, 'omzet': 9400000},
    {'day': 'Jum', 'transactions': 20, 'omzet': 6800000},
    {'day': 'Sab', 'transactions': 25, 'omzet': 8200000},
  ];

  // ===== SUMMARY — dihitung otomatis dari weekly =====
  static int get totalTransaksi =>
      weekly.fold(0, (sum, e) => sum + (e['transactions'] as int));

  static int get totalOmzet =>
      weekly.fold(0, (sum, e) => sum + (e['omzet'] as int));

  static int get rataRataPerHari => totalOmzet ~/ weekly.length;

  static int get totalProdukTerjual => weekly.length * 8; // simulasi
}
