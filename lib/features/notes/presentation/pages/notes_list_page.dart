import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/note_model.dart';
import '../../data/note_box_provider.dart';
import 'add_note_page.dart';
import 'note_detail_page.dart';

class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(notesBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Notes'), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<NoteModel> notesBox, _) {
          if (notesBox.isEmpty) {
            return const Center(child: Text('Belum ada catatan 📝'));
          }

          return ListView.builder(
            itemCount: notesBox.length,
            itemBuilder: (context, index) {
              final note = notesBox.getAt(index);

              if (note == null) {
                return const SizedBox.shrink();
              }

              return Dismissible(
                key: ValueKey(note.key),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  // 🔑 SIMPAN DATA + KEY (IDENTITY STABIL)
                  final deletedKey = note.key as int;
                  final deletedTitle = note.title;
                  final deletedContent = note.content;
                  final deletedCreatedAt = note.createdAt;

                  // HAPUS BERDASARKAN KEY (BUKAN INDEX)
                  box.delete(deletedKey);

                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        content: const Text('Catatan dihapus'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            final restoredNote = NoteModel(
                              title: deletedTitle,
                              content: deletedContent,
                              createdAt: deletedCreatedAt,
                            );

                            // RESTORE DENGAN KEY ASLI
                            box.put(deletedKey, restoredNote);
                          },
                        ),
                      ),
                    );
                },
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailPage(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
