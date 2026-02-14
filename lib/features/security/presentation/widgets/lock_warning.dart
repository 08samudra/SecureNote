import 'package:flutter/material.dart';

class LockWarning extends StatelessWidget {
  final int attempts;

  const LockWarning({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Percobaan salah: $attempts / 12',
          style: const TextStyle(color: Colors.orange),
        ),
        if (attempts >= 10)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '⚠️ Hati-hati! Data akan terhapus pada 12x salah.',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
