// lib/core/network/dio_client.dart
//
// File ini tugasnya SATU:
// Jadi "jembatan" antara Flutter dan backend Go.
// Setiap request yang keluar dari app, PASTI lewat sini dulu.

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider supaya DioClient bisa diakses dari Repository mana saja
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

class DioClient {
  late final Dio _dio;

  // Sama seperti di auth_repository — satu storage, dipakai bersama
  final _storage = const FlutterSecureStorage();

  DioClient() {
    // ── Setup dasar Dio ────────────────────────────────────────────────────
    _dio = Dio(
      BaseOptions(
        // Ganti sesuai environment kamu:
        // Android emulator : http://10.0.2.2:8080/api/v1
        // iOS simulator    : http://127.0.0.1:8080/api/v1
        // HP fisik (WiFi)  : http://192.168.x.x:8080/api/v1
        // Production       : https://api.domainmu.com/api/v1
        baseUrl: 'http://localhost:8080/backend',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Pasang interceptor ─────────────────────────────────────────────────
    // Interceptor = "petugas" yang mencegat semua request & response
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest, // sebelum request dikirim
        onError: _onError, // kalau response error (401, 500, dll)
      ),
    );
  }

  // ── INTERCEPTOR 1: Tempel token di setiap request ─────────────────────────
  //
  // Ini dipanggil OTOMATIS sebelum setiap request dikirim ke Go.
  // Kamu tidak perlu tulis token manual di repository.
  //
  // Hasilnya setiap request yang keluar jadi seperti ini:
  //   GET /dashboard/item-terlaris
  //   Authorization: Bearer eyJhbGci...   ← otomatis dari sini
  //   Content-Type: application/json
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Baca access_token dari brankas HP
    final token = await _storage.read(key: 'access_token');

    // Kalau ada token, tempel di header
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // debugPrint('🔑 token: $token');

    // Lanjutkan request ke Go
    handler.next(options);
  }

  // ── INTERCEPTOR 2: Handle error dari Go ───────────────────────────────────
  //
  // Ini dipanggil OTOMATIS kalau Go balas dengan status error.
  // Kasus paling penting: 401 = token expired → minta token baru diam-diam.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Go balas 401 = "token kamu sudah tidak berlaku"
    if (error.response?.statusCode == 401) {
      // Coba refresh token diam-diam tanpa user tahu
      final berhasil = await _coba_refresh_token();

      if (berhasil) {
        // Ambil token baru yang sudah disimpan
        final tokenBaru = await _storage.read(key: 'access_token');

        // Pasang token baru ke request yang gagal tadi
        error.requestOptions.headers['Authorization'] = 'Bearer $tokenBaru';

        // Ulangi request yang gagal → user tidak sadar ada yang salah
        final retryResponse = await _dio.fetch(error.requestOptions);
        return handler.resolve(retryResponse);
      }

      // Refresh juga gagal → token benar-benar expired
      // Paksa logout: hapus semua token dari brankas
      await _storage.deleteAll();

      // Lempar error khusus supaya widget bisa redirect ke /login
      return handler.next(
        DioException(
          requestOptions: error.requestOptions,
          error: 'SESSION_EXPIRED', // widget tangkap string ini
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // Error lain (400, 404, 500, dll) → teruskan apa adanya
    handler.next(error);
  }

  // ── Minta token baru ke Go ─────────────────────────────────────────────────
  //
  // Endpoint Go: POST /auth/refresh
  // Body       : { "refresh_token": "..." }
  // Response   : { "access_token": "token_baru" }
  Future<bool> _coba_refresh_token() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');

      // Tidak ada refresh token → langsung gagal
      if (refreshToken == null) return false;

      // Pakai Dio BARU tanpa interceptor
      // Kalau pakai _dio yang sama, akan infinite loop (401 → refresh → 401 → ...)
      final plainDio = Dio(
        BaseOptions(baseUrl: 'http://localhost:8080/backend'),
      );
      final response = await plainDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      // Simpan access_token baru ke brankas
      final tokenBaru = response.data['access_token'] as String;
      await _storage.write(key: 'access_token', value: tokenBaru);

      return true; // berhasil dapat token baru
    } catch (_) {
      // refresh_token juga expired atau invalid
      return false;
    }
  }

  // ── Shortcut method yang dipakai di Repository ─────────────────────────────
  //
  // Repository tidak perlu akses _dio langsung,
  // cukup panggil method di bawah ini.

  // GET — ambil data
  // Contoh: _client.get('/dashboard/item-terlaris', params: {'periode': 'mingguan'})
  Future<Response> get(String path, {Map<String, String>? params}) =>
      _dio.get(path, queryParameters: params);

  // POST — kirim data baru
  // Contoh: _client.post('/produk', data: produk.toJson())
  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  // PUT — update data yang sudah ada
  // Contoh: _client.put('/produk/5', data: produk.toJson())
  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  // DELETE — hapus data
  // Contoh: _client.delete('/produk/5')
  Future<Response> delete(String path) => _dio.delete(path);

  // Di dio_client.dart
  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);
}
