import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import 'package:SecureNote/core/widgets/base_app_bar.dart';
import '../../data/note_model.dart';
import 'add_note_page.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart';

class NoteDetailPage extends StatelessWidget {
  final int noteKey;

  const NoteDetailPage({super.key, required this.noteKey});

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('notesBox')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final box = Hive.box<NoteModel>('notesBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [noteKey]),
      builder: (context, Box<NoteModel> notesBox, _) {
        final note = notesBox.get(noteKey);

        if (note == null) {
          return const Scaffold(
            body: EmptyState(
              message: 'Note not found',
              icon: Icons.error_outline,
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,

          // ================= APP BAR =================
          appBar: BaseAppBar(
            title: 'Note Details',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
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

          // ================= BODY =================
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DATE =================
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // ================= TITLE =================
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                Divider(
                  color: AppColors.mainBlue.withValues(alpha: 0.3),
                  thickness: 1,
                ),

                const SizedBox(height: 2),

                // ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: TextEditingController(text: note.content),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x553A6EA5),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x553A6EA5),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
