import 'package:flutter/material.dart';
import 'package:SecureNote/features/security/service/lock_service.dart';
import 'package:SecureNote/features/security/service/pin_rotation_service.dart';

class ChangePinController extends ChangeNotifier {
  final oldPin = TextEditingController();
  final newPin = TextEditingController();
  final confirmPin = TextEditingController();

  final _lockService = LockService();

  String? error;
  bool loading = false;

  Future<bool> changePin() async {
    error = null;
    loading = true;
    notifyListeners();

    final result = await _lockService.verifyPin(oldPin.text);

    if (result != PinResult.success) {
      error = 'PIN lama salah';
      loading = false;
      notifyListeners();
      return false;
    }

    if (newPin.text.length < 4) {
      error = 'PIN minimal 4 digit';
      loading = false;
      notifyListeners();
      return false;
    }

    if (newPin.text != confirmPin.text) {
      error = 'PIN baru tidak sama';
      loading = false;
      notifyListeners();
      return false;
    }

    await PinRotationService.rotatePin(
      oldPin: oldPin.text,
      newPin: newPin.text,
    );

    await _lockService.savePin(newPin.text);

    loading = false;
    notifyListeners();
    return true;
  }

  void disposeController() {
    oldPin.dispose();
    newPin.dispose();
    confirmPin.dispose();
  }
}
