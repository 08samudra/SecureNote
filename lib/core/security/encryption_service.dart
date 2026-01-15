import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // 🔑 AES-256 key (32 byte)
  static final Key _key = Key.fromUtf8('0123456789abcdef0123456789abcdef');

  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypt plaintext → base64(iv):base64(cipher)
  static String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16); // AES block size
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt base64(iv):base64(cipher) → plaintext
  static String decrypt(String cipherText) {
    final parts = cipherText.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted data format');
    }

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    return _encrypter.decrypt(encrypted, iv: iv);
  }
}
