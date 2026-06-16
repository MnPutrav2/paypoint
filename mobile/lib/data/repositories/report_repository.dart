import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/network/dio_client.dart';
import '../models/report.dart';

class ReportRepository {
  final DioClient dio;

  ReportRepository({required this.dio});

  T _extractData<T>(Response response, T Function(dynamic) parser) {
    final body = response.data as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    if (!success) {
      throw Exception(body['message'] ?? 'Terjadi kesalahan dari server');
    }
    return parser(body['result']);
  }

  // GET /report — fetch semua data awal
  Future<ReportModel> getReport() async {
    try {
      final response = await dio.get('/dashboard');
      return _extractData(response, (data) => ReportModel.fromJson(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // GET /report/grafik?target=grafik_omzet&mode=Bulan
  Future<List<GrafikItem>> getGrafik({
    required String target, // 'grafik_omzet' | 'grafik_item_terlaris'
    required String mode, // 'Minggu' | 'Bulan' | 'Tahun'
  }) async {
    try {
      final response = await dio.get('/order/$target', params: {'mode': mode});
      return _extractData<List<GrafikItem>>(
        response,
        (data) => (data as List).map((e) => GrafikItem.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, coba lagi';
      case DioExceptionType.badResponse:
        final msg = e.response?.data?['message'];
        return msg ?? 'Server error (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(dio: ref.watch(dioClientProvider));
});
