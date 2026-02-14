import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import '../../data/note_model.dart';
import '../providers/search_provider.dart';
import 'add_note_page.dart';
import '../widgets/notes_app_bar.dart';
import '../widgets/note_list_item.dart';
import '../widgets/empty_state.dart';

class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Hive.isBoxOpen('notesBox')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final box = Hive.box<NoteModel>('notesBox');
    final isSearching = ref.watch(isSearchingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NotesAppBar(),
      body: Column(
        children: [
          if (isSearching)
            Container(
              color: AppColors.darkNavy,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<NoteModel> notesBox, _) {
                if (notesBox.isEmpty) {
                  return const EmptyState(
                    message: 'No notes yet. Add your first note!',
                    icon: Icons.note_alt_outlined,
                  );
                }

                final query = ref.watch(searchQueryProvider).toLowerCase();

                final notes = notesBox.values.where((note) {
                  final title = note.title.trim();
                  final content = note.content.trim();

                  // 🔥 SKIP ghost note (decrypt gagal / kosong total)
                  if (title.isEmpty && content.isEmpty) {
                    return false;
                  }

                  if (query.isEmpty) {
                    return true;
                  }

                  return title.toLowerCase().contains(query) ||
                      content.toLowerCase().contains(query);
                }).toList();

                if (notes.isEmpty) {
                  return const EmptyState(
                    message: 'Note not found',
                    icon: Icons.search_off,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteListItem(note: note, box: notesBox);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNotePage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
