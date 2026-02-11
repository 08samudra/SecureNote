import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/security/lock_service.dart';
import 'package:note_samtech/core/security/key_derivation_service.dart';
import 'package:note_samtech/core/security/session_key_manager.dart';
import '../../notes/data/note_model.dart';

class SetPinPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const SetPinPage({super.key, required this.onCompleted});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  final _lockService = LockService();

  String? _error;
  bool _loading = false;

  Future<void> _savePin() async {
    if (_loading) return;

    setState(() {
      _error = null;
    });

    if (_pin1.text.length < 4) {
      setState(() => _error = 'PIN minimal 4 digit');
      return;
    }

    if (_pin1.text != _pin2.text) {
      setState(() => _error = 'PIN tidak sama');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // 1️⃣ Simpan hash PIN
      await _lockService.savePin(_pin1.text);

      // 2️⃣ Derive session key
      final key = await KeyDerivationService.deriveKeyFromPin(_pin1.text);
      SessionKeyManager.setKey(key);

      // 3️⃣ Buka box jika belum terbuka
      if (!Hive.isBoxOpen('notesBox')) {
        await Hive.openBox<NoteModel>('notesBox');
      }

      // 4️⃣ Clear controller (security hygiene)
      _pin1.clear();
      _pin2.clear();

      // 5️⃣ Masuk app
      widget.onCompleted();
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan sistem';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
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
              textAlign: TextAlign.center,
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _savePin,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan & Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
