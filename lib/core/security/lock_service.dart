import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LockService {
  static const _pinKey = 'app_pin_hash';
  final _storage = const FlutterSecureStorage();

  // 🔐 HASH FUNCTION
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinKey);
    return hash != null;
  }

  Future<void> savePin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hash);
  }

  Future<bool> verifyPin(String inputPin) async {
    final savedHash = await _storage.read(key: _pinKey);
    if (savedHash == null) return false;

    final inputHash = _hashPin(inputPin);
    return inputHash == savedHash;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }
}
