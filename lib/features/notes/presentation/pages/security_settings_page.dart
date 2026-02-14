import 'package:flutter/material.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import 'package:SecureNote/core/widgets/base_app_bar.dart';
import 'package:SecureNote/features/security/presentation/pages/change_pin_page.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const BaseAppBar(title: 'Security'),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.mainBlue,
                  ),
                ),
                title: const Text(
                  'Change PIN',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                subtitle: const Text(
                  'Update your security PIN',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.mainBlue,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePinPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
