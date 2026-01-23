import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_samtech/core/security/key_derivation_service.dart';
import 'package:note_samtech/core/security/session_key_manager.dart';
import 'package:note_samtech/features/notes/data/note_model.dart';

class PinRotationService {
  static Future<void> rotatePin({
    required String oldPin,
    required String newPin,
  }) async {
    final oldKey = await KeyDerivationService.deriveKeyFromPin(oldPin);
    final newKey = await KeyDerivationService.deriveKeyFromPin(newPin);

    final box = Hive.box<NoteModel>('notesBox');

    // 1. Pakai old key dulu
    SessionKeyManager.setKey(oldKey);

    // 2. Simpan plaintext sementara di RAM
    final temp = box.values.map((note) {
      return {'note': note, 'title': note.title, 'content': note.content};
    }).toList();

    // 3. Ganti ke new key
    SessionKeyManager.setKey(newKey);

    // 4. Encrypt ulang semuanya
    for (final item in temp) {
      final note = item['note'] as NoteModel;
      note.update(
        title: item['title'] as String,
        content: item['content'] as String,
      );
    }

    // 5. Session key resmi sekarang newKey
    SessionKeyManager.setKey(newKey);
  }
}
