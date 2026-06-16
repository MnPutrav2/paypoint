import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/data/models/kategori_model.dart';
import 'package:kasir_offline/data/repositories/kategory_repository.dart';

final kategoriListProvider =
    FutureProvider.family<List<KategoriModel>, String?>((
      ref,
      kategoriRef,
    ) async {
      final repository = ref.watch(kategoriRepositoryProvider);

      return repository.getAll(kategoriRef);
    });

// final kategoriListProvider = FutureProvider<List<KategoriModel>>((ref) async {
//   return ref.read(produkRepositoryProvider).getKategori();
// });
