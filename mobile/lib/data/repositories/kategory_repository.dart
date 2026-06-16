import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import 'package:kasir_offline/data/models/kategori_model.dart';

class KategoriRepository {
  final DioClient dio;

  KategoriRepository({required this.dio});

  Future<List<KategoriModel>> getAll([String? ref]) async {
    final response = await dio.get(
      '/kategori',
      params: ref != null && ref.isNotEmpty ? {'ref': ref} : null,
    );

    final result = response.data['result'] as List<dynamic>;

    return result
        .map((e) => KategoriModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final kategoriRepositoryProvider = Provider<KategoriRepository>((ref) {
  return KategoriRepository(dio: ref.watch(dioClientProvider));
});
