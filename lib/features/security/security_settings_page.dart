import 'package:flutter/material.dart';
import '../../../core/security/lock_service.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _lockService = LockService();

  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  void _checkPin() async {
    final hasPin = await _lockService.hasPin();
    setState(() {
      _hasPin = hasPin;
    });
  }

  Future<void> _setPin(BuildContext context) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN baru'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == confirmController.text &&
                  pinController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _lockService.savePin(pinController.text);
      _checkPin();
    } else if (result == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN tidak cocok')));
    }
  }

  Future<void> _disablePin() async {
    await _lockService.clearPin();
    _checkPin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('App Lock (PIN)'),
            subtitle: Text(_hasPin ? 'Aktif' : 'Tidak aktif'),
            value: _hasPin,
            onChanged: (value) {
              if (value) {
                _setPin(context);
              } else {
                _disablePin();
              }
            },
          ),
        ],
      ),
    );
  }
}
