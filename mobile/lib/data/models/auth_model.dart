// lib/data/models/auth_model.dart

// ── Request: yang dikirim ke Go ──────────────────────────────────────────────
// Setara dengan `values` di Formik Next.js
import 'package:dio/dio.dart';

class LoginRequest {
  final String username; // bisa email atau username
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

// ── Response: yang diterima dari Go ─────────────────────────────────────────
// Go akan kirim: { "data": { "access_token": "...", "refresh_token": "..." }, "message": "success" }
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String message;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final result =
        json['result'] as Map<String, dynamic>; // ← ganti 'data' → 'result'
    return LoginResponse(
      accessToken: result['access_token'] as String,
      refreshToken: result['refresh_token'] as String,
      message: json['message'] as String? ?? 'success',
    );
  }
}

class RegisterRequest {
  final String username;
  final String name;
  final String phoneNumber;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterRequest({
    required this.username,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'nama': name,
    'nomor_telepon': phoneNumber,
    'email': email,
    'password': password,
    'confirm_password': confirmPassword,
  };

  FormData toFormData() => FormData.fromMap({
      'username': username,
      'nama': name,
      'nomor_telepon': phoneNumber,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
}

// ── Register Response: yang diterima dari Go ─────────────────────────────────
// { "message": "Akun berhasil dibuat" }
// (tidak langsung dapat token — user harus login dulu)
class RegisterResponse {
  final String message;

  const RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String? ?? 'Akun berhasil dibuat',
    );
  }
}
