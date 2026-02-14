import 'package:flutter/material.dart';

class LockCountdown extends StatelessWidget {
  final int seconds;

  const LockCountdown({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        'Terkunci selama $seconds detik',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      ),
    );
  }
}
