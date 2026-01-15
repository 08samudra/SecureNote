import 'package:flutter/material.dart';
import '../../../core/security/lock_service.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreenPage({super.key, required this.onUnlocked});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  final _controller = TextEditingController();
  final _lockService = LockService();
  String? _error;

  void _unlock() async {
    final success = await _lockService.verifyPin(_controller.text);

    if (success) {
      widget.onUnlocked(); // 🔥 unlock AppGate
    } else {
      setState(() {
        _error = 'PIN salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            const Text('Masukkan PIN'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _unlock, child: const Text('Buka')),
          ],
        ),
      ),
    );
  }
}
