import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../service/lock_service.dart';
import '../service/key_derivation_service.dart';
import '../service/session_key_manager.dart';
import '../../notes/data/note_model.dart';

class SetPinController extends ChangeNotifier {
  final LockService _lockService = LockService();

  final TextEditingController pin1 = TextEditingController();
  final TextEditingController pin2 = TextEditingController();

  String? error;
  bool loading = false;

  Future<bool> savePin() async {
    if (loading) return false;

    error = null;

    if (pin1.text.length < 4) {
      error = 'PIN minimal 4 digit';
      notifyListeners();
      return false;
    }

    if (pin1.text != pin2.text) {
      error = 'PIN tidak sama';
      notifyListeners();
      return false;
    }

    loading = true;
    notifyListeners();

    try {
      // 🔐 1. Simpan hash PIN
      await _lockService.savePin(pin1.text);

      // 🔑 2. Derive session key
      final key = await KeyDerivationService.deriveKeyFromPin(pin1.text);
      SessionKeyManager.setKey(key);

      // 📦 3. Pastikan box terbuka fresh
      if (!Hive.isBoxOpen('notesBox')) {
        await Hive.openBox<NoteModel>('notesBox');
      }

      pin1.clear();
      pin2.clear();

      return true;
    } catch (e, stack) {
      debugPrint('SET PIN ERROR: $e');
      debugPrintStack(stackTrace: stack);
      error = 'Terjadi kesalahan sistem';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pin1.dispose();
    pin2.dispose();
    super.dispose();
  }
}
