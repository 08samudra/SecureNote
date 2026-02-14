import 'package:flutter/material.dart';
import 'package:SecureNote/core/theme/app_colors.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const PinInputField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true, // 🔥 tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      enabled: enabled, // 🔥 ini penting
      style: const TextStyle(color: Colors.black),
      cursorColor: AppColors.mainBlue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.mainBlue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
