import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum PinResult { success, failed, locked, wiped }

class LockService {
  static const _pinKey = 'app_pin_hash';
  static const _failedAttemptsKey = 'failed_attempts';
  static const _lockUntilKey = 'lock_until';

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

    // Reset brute force state
    await _clearLockState();
  }

  Future<PinResult> verifyPin(String inputPin) async {
    final now = DateTime.now();

    // 🔒 Check lock timer
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

    // ❌ PIN SALAH
    int attempts = await getFailedAttempts();
    attempts++;

    await _setFailedAttempts(attempts);

    // 5x salah → lock 30 detik
    if (attempts == 5) {
      await _setLockUntil(DateTime.now().add(const Duration(seconds: 30)));
    }

    // 12x salah → PANIC WIPE
    if (attempts >= 12) {
      await _panicWipe();
      return PinResult.wiped;
    }

    // Rate limit delay
    await Future.delayed(const Duration(seconds: 2));

    return PinResult.failed;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  // =============================
  // 🔐 Brute Force Helpers
  // =============================

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

  // =============================
  // 💣 PANIC WIPE (SAFE FINAL)
  // =============================

  Future<void> _panicWipe() async {
    try {
      // 1️⃣ Hapus PIN
      await clearPin();

      // 2️⃣ Hapus box Hive dari disk
      await Hive.deleteBoxFromDisk('notesBox');

      // 3️⃣ Delay kecil untuk pastikan IO flush
      await Future.delayed(const Duration(milliseconds: 300));

      // 4️⃣ Reset brute state
      await _clearLockState();
    } catch (e) {
      print('Panic wipe error: $e');
    }
  }
}
