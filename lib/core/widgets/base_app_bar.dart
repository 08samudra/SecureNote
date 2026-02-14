import 'package:flutter/material.dart';
import 'package:SecureNote/core/theme/app_colors.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const BaseAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkNavy,
      elevation: 0,
      centerTitle: true,

      iconTheme: const IconThemeData(color: Colors.white),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // 🔥 WAJIB PUTIH
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
