import 'package:flutter/material.dart';
import 'package:note_samtech/core/security/lock_service.dart';
import 'package:note_samtech/core/security/pin_rotation_service.dart';
import 'package:flutter/services.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _oldPin = TextEditingController();
  final _newPin = TextEditingController();
  final _confirmPin = TextEditingController();

  final _lockService = LockService();
  String? _error;
  bool _loading = false;

  void _changePin() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final ok = await _lockService.verifyPin(_oldPin.text);
    if (!ok) {
      setState(() {
        _error = 'PIN lama salah';
        _loading = false;
      });
      return;
    }

    if (_newPin.text != _confirmPin.text) {
      setState(() {
        _error = 'PIN baru tidak sama';
        _loading = false;
      });
      return;
    }

    await PinRotationService.rotatePin(
      oldPin: _oldPin.text,
      newPin: _newPin.text,
    );

    await _lockService.savePin(_newPin.text);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _oldPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN Lama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN Baru'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi PIN Baru',
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _changePin,
                    child: const Text('Update PIN'),
                  ),
          ],
        ),
      ),
    );
  }
}
