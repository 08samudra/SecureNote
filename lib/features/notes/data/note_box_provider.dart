import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'note_model.dart';

final notesBoxProvider = FutureProvider<Box<NoteModel>>((ref) async {
  if (!Hive.isBoxOpen('notesBox')) {
    return await Hive.openBox<NoteModel>('notesBox');
  }
  return Hive.box<NoteModel>('notesBox');
});
