import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'note_model.dart';

final notesBoxProvider = Provider<Box<NoteModel>>((ref) {
  return Hive.box<NoteModel>('notesBox');
});
