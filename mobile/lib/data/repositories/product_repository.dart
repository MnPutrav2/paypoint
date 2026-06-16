import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import 'package:kasir_offline/data/models/katalog.dart';
import '../models/product.dart';
import '../models/kategori_model.dart';

class ProdukRepository {
  final DioClient dio;

  ProdukRepository({required this.dio});

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Go response: { "status": "success", "data": ... }
  T _extractData<T>(Response response, T Function(dynamic) parser) {
    final body = response.data as Map<String, dynamic>;

    final success = body['success'] as bool? ?? false;

    if (!success) {
      throw Exception(
        body['message']?.toString() ?? 'Terjadi kesalahan dari server',
      );
    }

    return parser(body['result']);
  }

  // ─── READ LIST (GET /produk) ───────────────────────────────────────────────

  Future<List<Product>> getAll({String? search}) async {
    try {
      final response = await dio.get(
        '/produk',
        params: {if (search != null && search.isNotEmpty) 'search': search},
      );

      return _extractData<List<Product>>(
        response,
        (data) => (data as List).map((e) => Product.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── READ SINGLE (GET /produk/:id) ────────────────────────────────────────

  Future<Product> getProductById(int id) async {
    try {
      final response = await dio.get('/produk/$id');
      return _extractData<Product>(response, (data) => Product.fromJson(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── CREATE (POST /produk) ─────────────────────────────────────────────────

  Future<Product> tambahProduk({
    required String nama,
    required String detail,
    required int harga,
    required String kategoriId,
    File? foto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nama': nama,
        'detail': detail,
        'harga': harga.toString(),
        'kategori_id': kategoriId,
        if (foto != null)
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last,
          ),
      });

      final response = await dio.post('/produk', data: formData);

      return _extractData<Product>(response, (data) => Product.fromJson(data));
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DIO ERROR');
        print('MESSAGE: ${e.message}');
        print('STATUS: ${e.response?.statusCode}');
        print('RESPONSE: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // ─── UPDATE (PUT /produk/:id) ──────────────────────────────────────────────
  // Go support PUT langsung — kalau ada foto pakai multipart, kalau tidak pakai JSON

  Future<Product> updateProduct({
    required String id,
    required String nama,
    required String detail,
    required double harga,
    required int kategoriId,
    File? foto,
  }) async {
    try {
      late Response response;

      if (foto != null) {
        // Ada foto baru → multipart
        final formData = FormData.fromMap({
          'nama': nama,
          'detail': detail,
          'harga': harga.toString(),
          'kategori_id': kategoriId.toString(),
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last,
          ),
        });
        response = await dio.put('/produk/$id', data: formData);
      } else {
        // Tidak ganti foto → JSON biasa
        response = await dio.put(
          '/produk/$id',
          data: {
            'nama': nama,
            'detail': detail,
            'harga': harga,
            'kategori_id': kategoriId,
          },
        );
      }

      return _extractData<Product>(response, (data) => Product.fromJson(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  // ─── PATCH (PATCH /produk/:id) ─────────────────────────────────────────────
  // Partial update: hanya field yang dikirim yang berubah

  Future<Product> patchProduct({
    required String id,
    String? nama,
    String? detail,
    double? harga,
    String? kategoriId,
    File? foto,
  }) async {
    late Response response;

    try {
      if (foto != null) {
        // Ada foto baru → multipart (hanya kirim field yang tidak null)
        final Map<String, dynamic> fields = {
          if (nama != null) 'nama': nama,
          if (detail != null) 'detail': detail,
          if (harga != null) 'harga': harga.toInt(),
          if (kategoriId != null) 'kategori_id': kategoriId.toString(),
          'foto': await MultipartFile.fromFile(
            foto.path,
            filename: foto.path.split('/').last,
          ),
        };
        response = await dio.patch(
          '/produk/$id',
          data: FormData.fromMap(fields),
        );
      } else {
        // Tidak ada foto → JSON, hanya kirim field yang tidak null
        final Map<String, dynamic> body = {
          if (nama != null) 'nama': nama,
          if (detail != null) 'detail': detail,
          if (harga != null) 'harga': harga.toInt(),
          if (kategoriId != null) 'kategori_id': kategoriId,
        };
        response = await dio.patch('/produk/$id', data: body);
      }
      return _extractData<Product>(response, (data) {
        // Convert [{key: 'nama', value: ...}, ...] → {'nama': ..., ...}
        final map = <String, dynamic>{};
        for (final item in (data as List)) {
          final key = item['key'] as String;
          final value = item['value'];
          if (key == 'kategori_id') {
            map['kategori'] = value; // sesuaikan dengan key di Product.fromJson
          } else {
            map[key] = value;
          }
        }
        map['id'] = id;
        // print('CONVERTED MAP: $map'); // hapus setelah confirmed ok
        return Product.fromJson(map);
      });
      //   return _extractData<Product>(
      //     response,
      //     (data) => Product.fromJson((data as List).first),
      //   );
    } on DioException catch (e) {
      if (kDebugMode) {
        print('RESPONSE STATUS: ${e.response?.statusCode}');
        print('RESPONSE BODY  : ${e.response?.data}');
      }
      throw _handleDioError(e);
    }
  }
  // ─── DELETE (DELETE /produk/:id) ──────────────────────────────────────────

  Future<void> deleteProduct(String id) async {
    try {
      final response = await dio.delete('/produk/$id');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Gagal menghapus produk');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Kategori (GET /kategori) ──────────────────────────────────────────────

  Future<List<KategoriModel>> getKategori() async {
    try {
      final response = await dio.get('/kategori');
      return _extractData<List<KategoriModel>>(
        response,
        (data) => (data as List).map((e) => KategoriModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── PATCH (PATCH /produk/:id) ─────────────────────────────────────────────
  // Partial update: hanya field yang dikirim yang berubah

  Future<KatalogResponse> postKatalog({
    required String productId,
    double? harga,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      body['produk_id'] = productId;
      if (harga != null) {
        body['harga'] = harga.toInt();
      }
      final response = await dio.post('/katalog', data: body);

      //   print(response.data['result']);
      return KatalogResponse.fromJson(response.data['result']);
    } on DioException catch (e) {
      //   print('ERROR TYPE: ${e.type}');
      //   print('ERROR MESSAGE: ${e.message}');
      //   print('ERROR RESPONSE: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<bool> patchKatalog({
    required String id,
    int? stok,
    double? harga,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (harga != null) {
        body['harga'] = harga.toInt();
      }
      //   final response =
      await dio.patch('/katalog/$id', data: body);

      return true;
    } on DioException catch (e) {
      print('ERROR TYPE: ${e.type}');
      print('ERROR MESSAGE: ${e.message}');
      print('ERROR RESPONSE: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  // ─── Error Handler ─────────────────────────────────────────────────────────

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, coba lagi';
      case DioExceptionType.badResponse:
        // Coba ambil pesan dari response Go
        final msg = e.response?.data?['message'];
        return msg ?? 'Server error (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}

final productRepositoryProvider = Provider<ProdukRepository>((ref) {
  return ProdukRepository(dio: ref.watch(dioClientProvider));
});
