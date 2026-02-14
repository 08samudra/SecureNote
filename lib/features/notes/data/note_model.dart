import 'package:hive/hive.dart';
import '../../security/service/encryption_service.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String titleEncrypted;

  @HiveField(1)
  String contentEncrypted;

  @HiveField(2)
  DateTime createdAt;

  NoteModel({
    required String title,
    required String content,
    required this.createdAt,
  }) : titleEncrypted = EncryptionService.encrypt(title),
       contentEncrypted = EncryptionService.encrypt(content);

  /// Decrypted title for UI
  String get title => EncryptionService.decrypt(titleEncrypted);

  /// Decrypted content for UI
  String get content => EncryptionService.decrypt(contentEncrypted);

  /// Update note with re-encryption
  void update({required String title, required String content}) {
    titleEncrypted = EncryptionService.encrypt(title);
    contentEncrypted = EncryptionService.encrypt(content);
    save();
  }
}
