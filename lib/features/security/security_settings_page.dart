import 'package:flutter/material.dart';
import '../../../core/security/lock_service.dart';
import '../security/presentation/change_pin_page.dart';

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
              if (!value) {
                _disablePin();
              }
            },
          ),
          if (_hasPin)
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Change PIN'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePinPage()),
                );
                _checkPin();
              },
            ),
        ],
      ),
    );
  }
}
