import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  static const _storage = FlutterSecureStorage();

  /// Ambil payload JWT
  static Future<Map<String, dynamic>?> getPayload() async {
    try {
      final token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        return null;
      }

      return JwtDecoder.decode(token);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    final payload = await getPayload();
    return payload?['id']?.toString();
  }

  static Future<String?> getUsername() async {
    final payload = await getPayload();
    return payload?['username']?.toString();
  }

  static Future<String?> getName() async {
    final payload = await getPayload();
    return payload?['nama']?.toString();
  }

  static Future<String?> getRole() async {
    final payload = await getPayload();
    return payload?['role']?.toString();
  }

  static Future<bool> isExpired() async {
    final token = await _storage.read(key: 'access_token');

    if (token == null) {
      return true;
    }

    return JwtDecoder.isExpired(token);
  }
}
