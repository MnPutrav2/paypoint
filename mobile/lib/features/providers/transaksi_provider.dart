import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kasir_offline/data/models/transaksi_model.dart';
import 'package:kasir_offline/data/repositories/transaksi_repository.dart';
import 'package:kasir_offline/features/providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BAGIAN 1: Proses Bayar (dari payment_page)
// ─────────────────────────────────────────────────────────────────────────────

class BayarState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const BayarState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  BayarState copyWith({bool? isLoading, bool? isSuccess, String? error}) =>
      BayarState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error, // null = clear error
      );
}

class BayarNotifier extends StateNotifier<BayarState> {
  final TransaksiRepository _repo;
  final Ref _ref;

  BayarNotifier(this._repo, this._ref) : super(const BayarState());

  // Sebelumnya: _konfirmasiBayar() di payment_page
  Future<void> bayar({required String namaCustomer, required int total}) async {
    state = state.copyWith(isLoading: true);
    try {
      final items = _ref.read(cartProvider).toPaymentItems;

      // 1. Buat order
      final result = await _repo.createOrder(
        namaCustomer: namaCustomer == 'Pembeli' ? '' : namaCustomer,
        total: total,
        items: items,
      );

      // 2. Langsung update status ke sudahBayar
      final orderId = result['result']['id'] as String;
      await _repo.updateStatus(
        id: orderId,
        statusInt: StatusTransaksi.sudahBayar, // 4
      );

      _ref.read(cartProvider.notifier).clear();
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const BayarState();
}

final bayarProvider = StateNotifierProvider<BayarNotifier, BayarState>((ref) {
  return BayarNotifier(ref.read(transaksiRepositoryProvider), ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// BAGIAN 2: Riwayat Transaksi (dari riwayat_page)
// ─────────────────────────────────────────────────────────────────────────────

// TransaksiParams tetap di sini supaya riwayat_page tinggal import dari satu tempat
class TransaksiParams {
  final String keyword;
  final int pageIndex;
  final String sortBy;

  const TransaksiParams({
    required this.keyword,
    required this.pageIndex,
    required this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      other is TransaksiParams &&
      other.keyword == keyword &&
      other.pageIndex == pageIndex &&
      other.sortBy == sortBy;

  @override
  int get hashCode => Object.hash(keyword, pageIndex, sortBy);
}

// Sebelumnya: transaksiProvider didefinisikan di riwayat_page.dart (tidak ideal)
// Dipindahkan ke sini supaya bisa dipakai di mana saja
final riwayatProvider =
    FutureProvider.family<TransaksiResponse, TransaksiParams>((ref, params) {
      final repo = ref.watch(transaksiRepositoryProvider);
      return repo.getTransaksi(
        keyword: params.keyword,
        pageIndex: params.pageIndex,
        pageSize: 10,
        sortBy: params.sortBy,
      );
    });

// ─────────────────────────────────────────────────────────────────────────────
// BAGIAN 3: Detail Invoice (dari invoice_page)
// ─────────────────────────────────────────────────────────────────────────────

// Sebelumnya: invoiceDetailProvider didefinisikan di invoice_page.dart (tidak ideal)
// Dipindahkan ke sini supaya provider tidak nyebar di file widget
final invoiceDetailProvider = FutureProvider.autoDispose
    .family<List<TransaksiItem>, String>((ref, id) {
      final repo = ref.watch(transaksiRepositoryProvider);
      return repo.getTransaksiDetail(id);
    });

// Update status transaksi (dari invoice_page._updateStatus)
class UpdateStatusState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const UpdateStatusState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  UpdateStatusState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) => UpdateStatusState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    error: error,
  );
}

class UpdateStatusNotifier extends StateNotifier<UpdateStatusState> {
  final TransaksiRepository _repo;

  UpdateStatusNotifier(this._repo) : super(const UpdateStatusState());

  // Sebelumnya: logika try/catch di _updateStatus() invoice_page
  Future<void> update({required String id, required int statusInt}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.updateStatus(id: id, statusInt: statusInt);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const UpdateStatusState();
}

final updateStatusProvider =
    StateNotifierProvider<UpdateStatusNotifier, UpdateStatusState>((ref) {
      return UpdateStatusNotifier(ref.read(transaksiRepositoryProvider));
    });