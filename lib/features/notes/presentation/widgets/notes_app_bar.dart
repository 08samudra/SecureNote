import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SecureNote/core/widgets/base_app_bar.dart';
import 'package:SecureNote/features/notes/presentation/pages/security_settings_page.dart';
import '../providers/search_provider.dart';

class NotesAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const NotesAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearching = ref.watch(isSearchingProvider);

    return BaseAppBar(
      title: isSearching ? '' : 'SecureNote',

      // 🔐 LEFT ICON
      leading: isSearching
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(isSearchingProvider.notifier).state = false;
                ref.read(searchQueryProvider.notifier).state = '';
              },
            )
          : IconButton(
              icon: const Icon(Icons.security),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SecuritySettingsPage(),
                  ),
                );
              },
            ),

      // 🔍 RIGHT ICON
      actions: [
        if (!isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ref.read(isSearchingProvider.notifier).state = true;
            },
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}
