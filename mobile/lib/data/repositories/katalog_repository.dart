import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import '../models/katalog_model.dart';
import '../models/order_model.dart';

final katalogRepositoryProvider = Provider<KatalogRepository>((ref) {
  return KatalogRepository(dio: ref.watch(dioClientProvider));
});

class KatalogRepository {
  final DioClient dio;

  KatalogRepository({required this.dio});

  Future<List<KatalogItem>> getKatalog() async {
    final response = await dio.get('/katalog');
    final result = response.data['result'] as List<dynamic>? ?? [];
    return result
        .map((e) => KatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> createOrder(OrderRequest request) async {
    final response = await dio.post('/order', data: request.toJson());
    return response.data as Map<String, dynamic>;
  }
}
