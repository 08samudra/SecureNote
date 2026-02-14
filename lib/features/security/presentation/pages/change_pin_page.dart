import 'package:flutter/material.dart';
import '../../controller/change_pin_controller.dart';
import '../widgets/pin_input_field.dart';
import 'package:SecureNote/core/theme/app_colors.dart';
import 'package:SecureNote/core/widgets/base_app_bar.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  late ChangePinController controller;

  @override
  void initState() {
    super.initState();
    controller = ChangePinController();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(title: 'Change PIN'),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                PinInputField(controller: controller.oldPin, label: 'PIN Lama'),
                const SizedBox(height: 16),
                PinInputField(controller: controller.newPin, label: 'PIN Baru'),
                const SizedBox(height: 16),
                PinInputField(
                  controller: controller.confirmPin,
                  label: 'Konfirmasi PIN Baru',
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
                    onPressed: controller.loading
                        ? null
                        : () async {
                            final success = await controller.changePin();
                            if (success && mounted) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                    ),
                    child: controller.loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Update PIN',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
