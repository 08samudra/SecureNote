import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../notes/data/note_model.dart';
import '../../controller/lock_screen_controller.dart';
import '../widgets/pin_input_field.dart';
import '../widgets/security_logo.dart';
import '../widgets/lock_warning.dart';
import '../widgets/lock_countdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_app_bar.dart';
import '../../service/key_derivation_service.dart';
import '../../service/session_key_manager.dart';
import '../../service/lock_service.dart';
import '../widgets/panic_wipe_dialog.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback onPanicWipe;

  const LockScreenPage({
    super.key,
    required this.onUnlocked,
    required this.onPanicWipe,
  });

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  late LockScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = LockScreenController();
    controller.refreshStatus();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    final result = await controller.verify();

    switch (result) {
      case PinResult.success:
        final key = await KeyDerivationService.deriveKeyFromPin(
          controller.pinController.text,
        );

        SessionKeyManager.setKey(key);

        if (!Hive.isBoxOpen('notesBox')) {
          await Hive.openBox<NoteModel>('notesBox');
        }

        widget.onUnlocked();
        break;

      case PinResult.wiped:
        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const PanicWipeDialog(),
        );

        widget.onPanicWipe();
        break;

      case PinResult.locked:
      case PinResult.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BaseAppBar(title: 'Locked Notes'),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final isLocked =
                controller.lockUntil != null &&
                DateTime.now().isBefore(controller.lockUntil!);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                28,
                32,
                28,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                children: [
                  const SecurityLogo(),
                  const SizedBox(height: 16),

                  const Text(
                    'Enter your PIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 32),

                  PinInputField(
                    controller: controller.pinController,
                    label: 'PIN',
                    enabled: !isLocked,
                  ),

                  const SizedBox(height: 20),

                  if (controller.error != null)
                    Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.red),
                    ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLocked ? null : _handleUnlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Unlock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (controller.failedAttempts > 0 &&
                      controller.failedAttempts < 12)
                    LockWarning(attempts: controller.failedAttempts),

                  if (isLocked)
                    LockCountdown(seconds: controller.remainingSeconds),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
