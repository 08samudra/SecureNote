import 'package:flutter/material.dart';
import '../../controller/set_pin_controller.dart';
import '../widgets/pin_input_field.dart';
import '../widgets/security_logo.dart';
import 'package:SecureNote/core/theme/app_colors.dart';

class SetPinPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const SetPinPage({super.key, required this.onCompleted});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  late SetPinController controller;

  @override
  void initState() {
    super.initState();
    controller = SetPinController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await controller.savePin();
    if (success) {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                top: 32,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),

              child: Column(
                children: [
                  const SecurityLogo(),
                  const SizedBox(height: 8),
                  const Text(
                    'Set Security PIN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a PIN to protect your notes',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),

                  PinInputField(controller: controller.pin1, label: 'PIN'),
                  const SizedBox(height: 18),

                  PinInputField(
                    controller: controller.pin2,
                    label: 'Confirm PIN',
                  ),

                  const SizedBox(height: 20),

                  if (controller.error != null)
                    Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.loading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Save & Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
