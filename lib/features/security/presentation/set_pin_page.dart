import 'package:flutter/material.dart';
import '../../../core/security/lock_service.dart';
import 'package:note_samtech/core/security/key_derivation_service.dart';
import 'package:note_samtech/core/security/session_key_manager.dart';

class SetPinPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const SetPinPage({super.key, required this.onCompleted});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  String? _error;

  final _lockService = LockService();

  void _savePin() async {
    if (_pin1.text.length < 4) {
      setState(() => _error = 'PIN minimal 4 digit');
      return;
    }

    if (_pin1.text != _pin2.text) {
      setState(() => _error = 'PIN tidak sama');
      return;
    }

    await _lockService.savePin(_pin1.text);

    final key = await KeyDerivationService.deriveKeyFromPin(_pin1.text);
    SessionKeyManager.setKey(key);

    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Buat PIN untuk mengamankan catatan',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pin1,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pin2,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Simpan & Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
