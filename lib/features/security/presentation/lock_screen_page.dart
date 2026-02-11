import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/security/lock_service.dart';
import 'package:note_samtech/core/security/key_derivation_service.dart';
import 'package:note_samtech/core/security/session_key_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../notes/data/note_model.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback onPanicWipe;

  const LockScreenPage({
    super.key,
    required this.onUnlocked,
    required this.onPanicWipe,
  });

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  final _controller = TextEditingController();
  final _lockService = LockService();

  String? _error;
  int _failedAttempts = 0;
  DateTime? _lockUntil;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    final attempts = await _lockService.getFailedAttempts();
    final lockUntil = await _lockService.getLockUntil();

    if (!mounted) return;

    setState(() {
      _failedAttempts = attempts;
      _lockUntil = lockUntil;
    });

    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();

    if (_lockUntil == null) return;

    final now = DateTime.now();

    if (now.isAfter(_lockUntil!)) {
      setState(() {
        _remainingSeconds = 0;
      });
      return;
    }

    _remainingSeconds = _lockUntil!.difference(now).inSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = _lockUntil!.difference(DateTime.now()).inSeconds;

      if (diff <= 0) {
        timer.cancel();
        _refreshStatus();
      } else {
        setState(() {
          _remainingSeconds = diff;
        });
      }
    });
  }

  void _unlock() async {
    final pin = _controller.text;

    final result = await _lockService.verifyPin(pin);

    switch (result) {
      case PinResult.success:
        final key = await KeyDerivationService.deriveKeyFromPin(pin);
        SessionKeyManager.setKey(key);

        // 🔥 Buka kembali box setelah session key aktif
        await Hive.openBox<NoteModel>('notesBox');

        widget.onUnlocked();
        break;

      case PinResult.wiped:
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            title: Text('Data Dihapus'),
            content: Text(
              'Terlalu banyak percobaan gagal.\nSemua data telah dihapus demi keamanan.',
            ),
          ),
        );

        await Future.delayed(const Duration(seconds: 5));

        if (!mounted) return;

        Navigator.of(context).pop();
        widget.onPanicWipe();
        break;

      case PinResult.locked:
        await _refreshStatus();
        setState(() {
          _error = 'Terkunci sementara. Tunggu sebentar.';
        });
        break;

      case PinResult.failed:
        await _refreshStatus();
        setState(() {
          _error = 'PIN salah';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = _lockUntil != null && DateTime.now().isBefore(_lockUntil!);

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
              enabled: !isLocked,
              decoration: InputDecoration(
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isLocked ? null : _unlock,
              child: const Text('Buka'),
            ),

            const SizedBox(height: 16),

            if (_failedAttempts > 0 && _failedAttempts < 12)
              Text(
                'Percobaan salah: $_failedAttempts / 12',
                style: const TextStyle(color: Colors.orange),
              ),

            if (_failedAttempts >= 10 && _failedAttempts < 12)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Hati-hati! Data akan terhapus pada 12x salah.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Terkunci selama $_remainingSeconds detik',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
