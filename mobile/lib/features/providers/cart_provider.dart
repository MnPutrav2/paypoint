import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class CartState {
  final Map<String, KatalogItem> items; // id → item
  final Map<String, int> qty; // id → jumlah

  const CartState({this.items = const {}, this.qty = const {}});

  // Getter — sebelumnya ada di _CashierPageState & _CartPageState
  int get totalItem => qty.values.fold(0, (sum, q) => sum + q);

  int get totalHarga => qty.entries.fold(0, (sum, e) {
    final item = items[e.key];
    return sum + ((item?.harga ?? 0) * e.value);
  });

  // Helper: convert ke format List untuk dikirim ke payment / backend
  List<Map<String, dynamic>> get toPaymentItems => qty.entries.map((e) {
    final item = items[e.key]!;
    return {
      'id': item.id,
      'name': item.nama,
      'icon': item.icon ?? '🛍️',
      'qty': e.value,
      'harga': item.harga,
    };
  }).toList();

  CartState copyWith({
    Map<String, KatalogItem>? items,
    Map<String, int>? qty,
  }) => CartState(items: items ?? this.items, qty: qty ?? this.qty);
}

// ── Notifier ──────────────────────────────────────────────────────────────────
// Logika yang sebelumnya ada di _CashierPageState & _CartPageState
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Sebelumnya: _addToCart() di cashier_page
  void tambah(KatalogItem item) {
    final newItems = {...state.items, item.id: item};
    final newQty = {...state.qty, item.id: (state.qty[item.id] ?? 0) + 1};
    state = state.copyWith(items: newItems, qty: newQty);
  }

  // Sebelumnya: _updateQty(id, 1) di cart_page
  void tambahQty(String id) {
    final newQty = {...state.qty, id: (state.qty[id] ?? 0) + 1};
    state = state.copyWith(qty: newQty);
  }

  // Sebelumnya: _updateQty(id, -1) di cart_page
  void kurangiQty(String id) {
    final current = state.qty[id] ?? 0;
    if (current <= 1) {
      hapus(id);
      return;
    }
    final newQty = {...state.qty, id: current - 1};
    state = state.copyWith(qty: newQty);
  }

  // Sebelumnya: _removeItem() di cart_page
  void hapus(String id) {
    final newItems = {...state.items}..remove(id);
    final newQty = {...state.qty}..remove(id);
    state = state.copyWith(items: newItems, qty: newQty);
  }

  // Sebelumnya: _clearCart() di cart_page
  void clear() => state = const CartState();
}

// ── Provider ──────────────────────────────────────────────────────────────────
final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);