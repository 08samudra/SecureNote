import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import '../../data/note_model.dart';
import '../pages/note_detail_page.dart';
import 'package:intl/intl.dart';

class NoteListItem extends StatelessWidget {
  final NoteModel note;
  final Box<NoteModel> box;

  const NoteListItem({super.key, required this.note, required this.box});

  @override
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt);

    return Dismissible(
      key: ValueKey(note.key),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade600,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final deletedKey = note.key as int;
        final deletedTitle = note.title;
        final deletedContent = note.content;
        final deletedCreatedAt = note.createdAt;

        box.delete(deletedKey);

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.darkNavy,
              content: const Text('Catatan dihapus'),
              action: SnackBarAction(
                label: 'Undo',
                textColor: AppColors.accentBlue,
                onPressed: () {
                  final restoredNote = NoteModel(
                    title: deletedTitle,
                    content: deletedContent,
                    createdAt: deletedCreatedAt,
                  );

                  box.put(deletedKey, restoredNote);
                },
              ),
            ),
          );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // DATE
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mainBlue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailPage(noteKey: note.key as int),
            ),
          );
        },
      ),
    );
  }
}
