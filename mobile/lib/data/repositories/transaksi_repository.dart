import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import 'package:kasir_offline/data/models/order_model.dart';
import '../models/transaksi_model.dart';

final transaksiRepositoryProvider = Provider<TransaksiRepository>((ref) {
  return TransaksiRepository(dio: ref.watch(dioClientProvider));
});

class TransaksiRepository {
  final DioClient dio;

  TransaksiRepository({required this.dio});

  Future<TransaksiResponse> getTransaksi({
    int pageIndex = 0,
    int pageSize = 10,
    String keyword = '',
    String sortBy = 'terbaru',
  }) async {
    String orderBy;
    String orderDir;

    switch (sortBy) {
      case 'terlama':
        orderBy = 'created_at';
        orderDir = 'desc'; // ← desc = terlama di BE
        break;
      case 'nama_az':
        orderBy = 'nama_customer';
        orderDir = 'asc';
        break;
      default: // terbaru
        orderBy = 'created_at';
        orderDir = 'asc'; // ← asc = terbaru di BE
    }

    // ✅ Build params dulu, baru tambah keyword kalau ada
    final params = <String, String>{
      'page': pageIndex.toString(),
      'size': pageSize.toString(),
      'sort_column': orderBy,
      'sort_direction': orderDir,
    };

    if (keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }

    final response = await dio.get('/order', params: params);
    debugPrint('📦 URL: ${response.realUri}');
    debugPrint(
      '📦 first item: ${(response.data['result'] as List?)?.first?['invoice']}',
    );
    debugPrint(
      '📦 first created_at: ${(response.data['result'] as List?)?.first?['created_at']}',
    );

    return TransaksiResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateStatus({
    required String id,
    required int statusInt,
  }) async {
    // debugPrint('📦 PATCH /order/$id body: ${{'status_int': statusInt}}');
    await dio.patch('/order/$id', data: {'status': statusInt});
  }

  //   Future<void> updateStatus({
  //   required String id,
  //   required int statusInt,
  // }) async {
  //   try {
  //     await dio.patch('/order/$id', data: {'status_int': statusInt});
  //   } on DioException catch (e) {
  //     debugPrint('❌ response body: ${e.response?.data}');
  //     rethrow;
  //   }
  // }

  Future<List<TransaksiItem>> getTransaksiDetail(String id) async {
    final response = await dio.get('/order/$id');

    final itemList = (response.data['result'] as List<dynamic>)
        .map((e) => TransaksiItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return itemList;
  }

  Future<Map<String, dynamic>> createOrder({
    required String namaCustomer,
    required int total,
    required List<Map<String, dynamic>> items,
  }) async {
    final request = OrderRequest(
      namaCustomer: namaCustomer,
      catatan: '',
      total: total,
      orderItem: items
          .map(
            (item) => OrderItemRequest(
              katalogId: item['id'] as String,
              jumlah: item['qty'] as int,
              subtotal: (item['harga'] as int) * (item['qty'] as int),
            ),
          )
          .toList(),
    );

    final response = await dio.post('/order', data: request.toJson());
    return response.data as Map<String, dynamic>;
  }
}
