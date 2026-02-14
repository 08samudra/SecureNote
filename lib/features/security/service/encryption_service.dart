import 'package:encrypt/encrypt.dart';
import 'session_key_manager.dart';

class EncryptionService {
  static Encrypter _getEncrypter() {
    final key = SessionKeyManager.getKey();
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  static String encrypt(String plainText) {
    if (plainText.trim().isEmpty) {
      return ''; // 🔐 Jangan encrypt string kosong
    }

    final iv = IV.fromSecureRandom(16);
    final encrypted = _getEncrypter().encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decrypt(String cipherText) {
    try {
      final parts = cipherText.split(':');

      if (parts.length != 2) return '';

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      return _getEncrypter().decrypt(encrypted, iv: iv);
    } catch (e) {
      // 🔥 Jika key salah / data corrupt / pad block invalid
      return '';
    }
  }
}
