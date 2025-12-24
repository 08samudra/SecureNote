import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/note_model.dart';
import '../../data/note_box_provider.dart';
import '../providers/search_provider.dart';
import 'add_note_page.dart';
import 'note_detail_page.dart';

class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(notesBoxProvider);

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final isSearching = ref.watch(isSearchingProvider);

            if (isSearching) {
              return TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari catatan...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              );
            }

            return const Text('SecureNote');
          },
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isSearching = ref.watch(isSearchingProvider);

              if (isSearching) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(isSearchingProvider.notifier).state = false;
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                );
              }

              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ref.read(isSearchingProvider.notifier).state = true;
                },
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<NoteModel> notesBox, _) {
          if (notesBox.isEmpty) {
            return const Center(child: Text('Belum ada catatan 📝'));
          }
          final query = ref.watch(searchQueryProvider).toLowerCase();

          final notes = notesBox.values.where((note) {
            return note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query);
          }).toList();

          if (notes.isEmpty) {
            return const Center(child: Text('Catatan tidak ditemukan 🔍'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

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
                        builder: (_) =>
                            NoteDetailPage(noteKey: note.key as int),
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
