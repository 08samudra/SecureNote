import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum PinResult { success, failed, locked, wiped }

class LockService {
  static const _pinKey = 'app_pin_hash';
  static const _failedAttemptsKey = 'failed_attempts';
  static const _lockUntilKey = 'lock_until';

  final _storage = const FlutterSecureStorage();

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
    await _clearLockState();
  }

  Future<PinResult> verifyPin(String inputPin) async {
    final now = DateTime.now();

    final lockUntil = await getLockUntil();
    if (lockUntil != null && now.isBefore(lockUntil)) {
      return PinResult.locked;
    }

    final savedHash = await _storage.read(key: _pinKey);
    if (savedHash == null) return PinResult.failed;

    final inputHash = _hashPin(inputPin);
    final success = inputHash == savedHash;

    if (success) {
      await _clearLockState();
      return PinResult.success;
    }

    int attempts = await getFailedAttempts();
    attempts++;
    await _setFailedAttempts(attempts);

    if (attempts == 5) {
      await _setLockUntil(DateTime.now().add(const Duration(seconds: 30)));
    }

    if (attempts >= 12) {
      return PinResult.wiped;
    }

    await Future.delayed(const Duration(seconds: 2));
    return PinResult.failed;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<int> getFailedAttempts() async {
    final value = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<void> _setFailedAttempts(int count) async {
    await _storage.write(key: _failedAttemptsKey, value: count.toString());
  }

  Future<DateTime?> getLockUntil() async {
    final value = await _storage.read(key: _lockUntilKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _setLockUntil(DateTime time) async {
    await _storage.write(key: _lockUntilKey, value: time.toIso8601String());
  }

  Future<void> _clearLockState() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockUntilKey);
  }

  // Future<void> _panicWipe() async {
  //   try {
  //     if (Hive.isBoxOpen('notesBox')) {
  //       await Hive.box('notesBox').clear();
  //     }

  //     if (Hive.isBoxOpen('securityBox')) {
  //       await Hive.box('securityBox').clear();
  //     }
  //     SessionKeyManager.clear();
  //     await clearPin();
  //     await _clearLockState();
  //   } catch (_) {}
  // }
}
