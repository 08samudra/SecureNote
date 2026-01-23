import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/note_model.dart';
import 'add_note_page.dart';

class NoteDetailPage extends StatelessWidget {
  final int noteKey;

  const NoteDetailPage({super.key, required this.noteKey});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NoteModel>('notesBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [noteKey]),
      builder: (context, Box<NoteModel> notesBox, _) {
        final note = notesBox.get(noteKey);

        if (note == null) {
          return const Scaffold(
            body: Center(child: Text('Catatan tidak ditemukan')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Catatan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddNotePage(note: note)),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //
                  SelectableText(
                    note.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  //
                  SelectableText(
                    note.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
