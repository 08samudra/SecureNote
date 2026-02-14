import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';

class KeyDerivationService {
  static const String _saltBox = 'securityBox';
  static const String _saltKey = 'salt';

  static const int _iterations = 150000;
  static const int _keyLength = 32; // 256-bit

  /// 🔐 Get existing salt or create secure random salt
  static Future<Uint8List> _getOrCreateSalt() async {
    final box = await Hive.openBox(_saltBox);

    if (box.containsKey(_saltKey)) {
      final stored = box.get(_saltKey) as String;
      return base64Decode(stored);
    }

    final newSalt = _generateSecureSalt();
    await box.put(_saltKey, base64Encode(newSalt));
    return newSalt;
  }

  /// 🔒 Generate cryptographically secure salt (16 bytes)
  static Uint8List _generateSecureSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  /// 🔑 Derive AES-256 key from PIN using proper PBKDF2
  static Future<Key> deriveKeyFromPin(String pin) async {
    final salt = await _getOrCreateSalt();
    final derivedKey = _pbkdf2(pin, salt);
    return Key(derivedKey);
  }

  /// 🔥 Proper PBKDF2-HMAC-SHA256
  static Uint8List _pbkdf2(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);

    final blockIndex = Uint8List(4);
    blockIndex[3] = 1; // First block (big endian 0x00000001)

    final initialInput = Uint8List.fromList([...salt, ...blockIndex]);

    Uint8List u = Uint8List.fromList(hmac.convert(initialInput).bytes);
    Uint8List result = Uint8List.fromList(u);

    for (int i = 1; i < _iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return Uint8List.fromList(result.sublist(0, _keyLength));
  }
}
