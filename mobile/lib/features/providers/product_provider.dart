import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import 'package:kasir_offline/data/models/katalog.dart';
import 'package:kasir_offline/features/providers/login_provider.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/product.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AUTH TOKEN — satu sumber kebenaran JWT di seluruh app
// Di-set oleh loginProvider setelah login sukses
// Di-restore oleh splashProvider saat app start
// ══════════════════════════════════════════════════════════════════════════════

// ─── Restore session saat app pertama dibuka ─────────────────────────────────
// Pakai di splash_screen.dart:
//   final token = await ref.read(restoreSessionProvider.future);

final restoreSessionProvider = FutureProvider<String?>((ref) async {
  final token = await ref.read(authRepositoryProvider).getAccessToken();
  if (token != null && token.isNotEmpty) {
    ref.read(authTokenProvider.notifier).state = token;
  }
  return token;
});

// ─── Repository (auto rebuild saat token berubah) ─────────────────────────

final produkRepositoryProvider = Provider<ProdukRepository>((ref) {
  return ProdukRepository(dio: ref.watch(dioClientProvider));
});
// ══════════════════════════════════════════════════════════════════════════════
// LIST PRODUK
// ══════════════════════════════════════════════════════════════════════════════

class ProdukListState {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const ProdukListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  ProdukListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? searchQuery,
    bool clearError = false,
  }) {
    return ProdukListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProdukListNotifier extends StateNotifier<ProdukListState> {
  final ProdukRepository _repo;

  ProdukListNotifier(this._repo) : super(const ProdukListState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final keyword = search ?? state.searchQuery;

      final data = await _repo.getAll(search: keyword);
      state = state.copyWith(
        products: data,
        isLoading: false,
        searchQuery: keyword,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> setSearch(String query) async {
    state = state.copyWith(searchQuery: query);
    await fetchProducts(search: query);
  }

  Future<bool> deleteProduct(String id) async {
    final backup = state.products;
    state = state.copyWith(
      products: state.products.where((p) => p.id != id).toList(),
    );
    try {
      await _repo.deleteProduct(id);
      return true;
    } catch (e) {
      state = state.copyWith(products: backup, errorMessage: e.toString());
      return false;
    }
  }

  void addProduct(Product product) {
    state = state.copyWith(products: [product, ...state.products]);
  }

  void updateProductInList(Product updated) {
    state = state.copyWith(
      products: state.products
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
  }

  void removeProductFromList(int id) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != id).toList(),
    );
  }
}

final produkListProvider =
    StateNotifierProvider<ProdukListNotifier, ProdukListState>(
      (ref) => ProdukListNotifier(ref.read(produkRepositoryProvider)),
    );

// ══════════════════════════════════════════════════════════════════════════════
// TAMBAH PRODUK
// ══════════════════════════════════════════════════════════════════════════════

class TambahProdukState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final File? selectedImage;

  const TambahProdukState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.selectedImage,
  });

  TambahProdukState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    File? selectedImage,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return TambahProdukState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
    );
  }
}

class TambahProdukNotifier extends StateNotifier<TambahProdukState> {
  final ProdukRepository _repo;

  TambahProdukNotifier(this._repo) : super(const TambahProdukState());

  void setImage(File? image) => state = state.copyWith(selectedImage: image);
  void clearError() => state = state.copyWith(clearError: true);

  Future<Product?> tambahProduk({
    required String nama,
    required String detail,
    required int harga,
    required String kategoriId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _repo.tambahProduk(
        nama: nama,
        detail: detail,
        harga: harga,
        kategoriId: kategoriId,
        foto: state.selectedImage,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return product;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  void reset() => state = const TambahProdukState();
}

final tambahProdukProvider =
    StateNotifierProvider.autoDispose<TambahProdukNotifier, TambahProdukState>(
      (ref) => TambahProdukNotifier(ref.read(produkRepositoryProvider)),
    );

// ══════════════════════════════════════════════════════════════════════════════
// EDIT PRODUK
// ══════════════════════════════════════════════════════════════════════════════

class EditProdukState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final File? selectedImage;

  const EditProdukState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.selectedImage,
  });

  EditProdukState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    File? selectedImage,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return EditProdukState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
    );
  }
}

class EditProdukNotifier extends StateNotifier<EditProdukState> {
  final ProdukRepository _repo;

  EditProdukNotifier(this._repo) : super(const EditProdukState());

  void setImage(File? image) => state = state.copyWith(selectedImage: image);
  void clearError() => state = state.copyWith(clearError: true);

  Future<Product?> updateProduct({
    required String id,
    required String nama,
    required String detail,
    required double harga,
    required int kategoriId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _repo.updateProduct(
        id: id,
        nama: nama,
        detail: detail,
        harga: harga,
        kategoriId: kategoriId,
        foto: state.selectedImage,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return product;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  // ── PATCH produk (partial update) ─────────────────────────────────────────
  Future<Product?> patchProduct({
    required String id,
    String? nama,
    String? detail,
    double? harga,
    String? kategoriId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _repo.patchProduct(
        id: id,
        nama: nama,
        detail: detail,
        harga: harga,
        kategoriId: kategoriId,
        foto: state.selectedImage, // null = tidak ganti foto
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return product;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<KatalogResponse> postKatalog({
    required String productId,
    double? harga,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final katalog = await _repo.postKatalog(
        productId: productId,
        harga: harga,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return katalog;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> patchKatalog({required String id, double? harga}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final product = await _repo.patchKatalog(id: id, harga: harga);

      //   print(product);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return product;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const EditProdukState();
}

final editProdukProvider =
    StateNotifierProvider.autoDispose<EditProdukNotifier, EditProdukState>(
      (ref) => EditProdukNotifier(ref.read(produkRepositoryProvider)),
    );

// ─── Kategori ──────────────────────────────────────────────────────────────
