import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';

class KeyDerivationService {
  static const String _saltBox = 'securityBox';
  static const String _saltKey = 'salt';

  /// Get existing salt or generate new one
  static Future<Uint8List> _getOrCreateSalt() async {
    final box = await Hive.openBox(_saltBox);

    if (box.containsKey(_saltKey)) {
      final stored = box.get(_saltKey) as String;
      return base64Decode(stored);
    }

    final newSalt = _generateSalt();
    await box.put(_saltKey, base64Encode(newSalt));
    return newSalt;
  }

  /// Generate random salt (16 bytes)
  static Uint8List _generateSalt() {
    final random = List<int>.generate(
      16,
      (_) => DateTime.now().microsecond % 256,
    );
    return Uint8List.fromList(random);
  }

  /// Derive AES-256 key from PIN
  static Future<Key> deriveKeyFromPin(String pin) async {
    final salt = await _getOrCreateSalt();
    final key = _pbkdf2(pin, salt);
    return Key(key);
  }

  /// PBKDF2 implementation
  static Uint8List _pbkdf2(String pin, Uint8List salt) {
    const int iterations = 100000;
    const int keyLength = 32; // 256-bit

    final hmac = Hmac(sha256, utf8.encode(pin));
    var result = Uint8List.fromList(hmac.convert(salt).bytes);

    for (int i = 1; i < iterations; i++) {
      result = Uint8List.fromList(hmac.convert(result).bytes);
    }

    return Uint8List.fromList(result.sublist(0, keyLength));
  }
}
