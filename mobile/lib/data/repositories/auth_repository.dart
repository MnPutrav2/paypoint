import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import 'package:kasir_offline/core/utils/encrypt_helper.dart'; // ← tambah

// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return AuthRepository();
// });

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

class AuthRepository {
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/backend',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  // ..interceptors.add(
  //   // ← tambah interceptor
  //   LogInterceptor(
  //     request: true,
  //     requestHeader: true,
  //     requestBody: true, // ← lihat payload yang dikirim
  //     responseHeader: false,
  //     responseBody: true, // ← lihat response dari server
  //     error: true, // ← lihat detail error
  //     logPrint: (o) => print('🌐 $o'),
  //   ),
  // );

  final _storage = const FlutterSecureStorage();

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Enkripsi payload sebelum dikirim — sama seperti Next.js
      final encrypted = EncryptHelper.encryptPayload({
        'type': 'password',
        'username': request.username,
        'password': request.password,
      });

      final response = await _dio.post(
        '/auth/login',
        data: {'payload': encrypted}, // ← format sama dengan Next.js
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _storage.write(
        key: 'access_token',
        value: loginResponse.accessToken,
      );
      await _storage.write(
        key: 'refresh_token',
        value: loginResponse.refreshToken,
      );

      return loginResponse;
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toFormData(),
      );
      return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.deleteAll(); // hapus access_token & refresh_token
  }

  // ── CEK SUDAH LOGIN ───────────────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // ── AMBIL TOKEN ───────────────────────────────────────────────────────────
  Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  // ── PARSE ERROR ───────────────────────────────────────────────────────────
  String _parseError(DioException e) {
    final serverMessage = e.response?.data is Map
        ? e.response?.data['message'] as String?
        : null;

    if (serverMessage != null) return serverMessage;

    switch (e.response?.statusCode) {
      case 400:
        return 'Data tidak valid, periksa kembali';
      case 401:
        return 'Username atau password salah';
      case 404:
        return 'Akun tidak ditemukan';
      case 409:
        return 'Email sudah terdaftar';
      case 500:
        return 'Server sedang bermasalah, coba lagi';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Koneksi timeout, coba lagi';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa konek ke server, cek koneksi internet';
        }
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
