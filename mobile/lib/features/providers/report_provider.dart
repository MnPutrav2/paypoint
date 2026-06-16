import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/report.dart';
import '../../data/repositories/report_repository.dart';

class ReportState {
  final ReportModel? data;
  final bool isLoading;
  final bool isGrafikLoading;
  final String? errorMessage;

  const ReportState({
    this.data,
    this.isLoading = false,
    this.isGrafikLoading = false,
    this.errorMessage,
  });

  ReportState copyWith({
    ReportModel? data,
    bool? isLoading,
    bool? isGrafikLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isGrafikLoading: isGrafikLoading ?? this.isGrafikLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repo;

  ReportNotifier(this._repo) : super(const ReportState()) {
    fetchReport();
  }

  Future<void> fetchReport() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repo.getReport();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Ganti grafik berdasarkan periode yang dipilih
  Future<void> fetchGrafik({
    required String target, // 'grafik_omzet' | 'grafik_item_terlaris'
    required String mode, // 'Minggu' | 'Bulan' | 'Tahun'
  }) async {
    if (state.data == null) return;
    state = state.copyWith(isGrafikLoading: true);
    try {
      final items = await _repo.getGrafik(target: target, mode: mode);

      // Update hanya grafik yang berubah, data lain tetap
      final updated = target == 'grafik_omzet'
          ? ReportModel(
              saldo: state.data!.saldo,
              totalOmzet: state.data!.totalOmzet,
              profitHariIni: state.data!.profitHariIni,
              totalProfit: state.data!.totalProfit,
              itemTerjual: state.data!.itemTerjual,
              transaksiBelumSelesai: state.data!.transaksiBelumSelesai,
              grafikOmzet: items, // ← update
              grafikItemTerlaris: state.data!.grafikItemTerlaris,
              prediksiOmzet: state.data!.prediksiOmzet,
              marketBasket: state.data!.marketBasket,
            )
          : ReportModel(
              saldo: state.data!.saldo,
              totalOmzet: state.data!.totalOmzet,
              profitHariIni: state.data!.profitHariIni,
              totalProfit: state.data!.totalProfit,
              itemTerjual: state.data!.itemTerjual,
              transaksiBelumSelesai: state.data!.transaksiBelumSelesai,
              grafikOmzet: state.data!.grafikOmzet,
              grafikItemTerlaris: items, // ← update
              prediksiOmzet: state.data!.prediksiOmzet,
              marketBasket: state.data!.marketBasket,
            );

      state = state.copyWith(data: updated, isGrafikLoading: false);
    } catch (e) {
      state = state.copyWith(
        isGrafikLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>(
  (ref) => ReportNotifier(ref.read(reportRepositoryProvider)),
);
