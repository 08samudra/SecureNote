import 'dart:async';
import 'package:flutter/material.dart';
import 'package:SecureNote/features/security/service/lock_service.dart';

class LockScreenController extends ChangeNotifier {
  final pinController = TextEditingController();
  final _lockService = LockService();

  String? error;
  int failedAttempts = 0;
  DateTime? lockUntil;
  int remainingSeconds = 0;
  Timer? _timer;

  Future<PinResult> verify() async {
    final result = await _lockService.verifyPin(pinController.text);
    await refreshStatus();
    return result;
  }

  Future<void> refreshStatus() async {
    failedAttempts = await _lockService.getFailedAttempts();
    lockUntil = await _lockService.getLockUntil();
    _startCountdown();
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();

    if (lockUntil == null) return;

    final now = DateTime.now();
    if (now.isAfter(lockUntil!)) return;

    remainingSeconds = lockUntil!.difference(now).inSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = lockUntil!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        refreshStatus();
      } else {
        remainingSeconds = diff;
        notifyListeners();
      }
    });
  }

  void disposeController() {
    _timer?.cancel();
    pinController.dispose();
  }
}
