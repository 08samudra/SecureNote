import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import 'package:SecureNote/core/widgets/base_app_bar.dart';
import '../../data/note_model.dart';

class AddNotePage extends StatefulWidget {
  final NoteModel? note; // null = add, ada = edit

  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late ScrollController _scrollController;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool get isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
    _scrollController.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkNavy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              'Title or content must be filled.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      return;
    }

    final box = Hive.box<NoteModel>('notesBox');

    if (isEdit) {
      final editedNote = NoteModel(
        title: title,
        content: content,
        createdAt: widget.note!.createdAt,
      );

      box.put(widget.note!.key, editedNote);
    } else {
      final newNote = NoteModel(
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );

      box.add(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: BaseAppBar(
        title: isEdit ? 'Edit Notes' : 'Add Note',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ), // 🔥 WAJIB TAMBAH
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                cursorColor: Colors.black,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x553A6EA5), // soft blue
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x883A6EA5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  isEdit ? 'Update' : 'Save',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
