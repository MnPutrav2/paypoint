import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class EncryptHelper {
  // Harus sama dengan KEY di .env Next.js
  static const _secret = 'PkFNzh9gApR8Nke7EWDTtg0I+J0qnfb/b2QwS/d7yi8=';

  static const _ivLength = 12;
  static const _tagLength = 16;

  /// Output: base64(iv + tag + ciphertext)
  /// Sama persis dengan encryptPayload() di Next.js
  static String encryptPayload(Map<String, dynamic> payload) {
    // 1. deriveKey: SHA-256 dari secret — sama seperti JS
    final key = Uint8List.fromList(sha256.convert(utf8.encode(_secret)).bytes);

    // 2. Random IV 12 bytes
    final iv = _randomBytes(_ivLength);

    // 3. Encode payload
    final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

    // 4. AES-GCM encrypt
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      true,
      AEADParameters(KeyParameter(key), _tagLength * 8, iv, Uint8List(0)),
    );
    final output = cipher.process(plaintext);

    // 5. PointyCastle: output = ciphertext + tag
    final cipherText = output.sublist(0, output.length - _tagLength);
    final tag = output.sublist(output.length - _tagLength);

    // 6. Gabung: iv + tag + ciphertext — sama seperti Buffer.concat([iv, tag, encrypted])
    final result = Uint8List.fromList([...iv, ...tag, ...cipherText]);

    // 7. Base64 encode
    return base64.encode(result);
  }

  static Uint8List _randomBytes(int length) {
    final random = FortunaRandom();
    random.seed(
      KeyParameter(
        Uint8List.fromList(
          List.generate(
            32,
            (_) => DateTime.now().microsecondsSinceEpoch & 0xFF,
          ),
        ),
      ),
    );
    return random.nextBytes(length);
  }
}
