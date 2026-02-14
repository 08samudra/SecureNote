import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SecureNote/features/security/service/lock_service.dart';
import 'package:SecureNote/features/security/presentation/pages/lock_screen_page.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/data/note_model.dart';
import 'features/notes/presentation/pages/notes_list_page.dart';
import 'features/security/service/session_key_manager.dart';
import 'package:SecureNote/features/security/presentation/pages/set_pin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();

  // Register Adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NoteModelAdapter());
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Samtech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> with WidgetsBindingObserver {
  final _lockService = LockService();

  bool _checked = false;
  bool _unlocked = false;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkLock() async {
    final hasPin = await _lockService.hasPin();

    if (!mounted) return; // 🔥 WAJIB

    setState(() {
      _checked = true;
      _hasPin = hasPin;
      _unlocked = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final hasPin = await _lockService.hasPin();

      if (!mounted) return;

      if (hasPin) {
        SessionKeyManager.clear();
        setState(() {
          _unlocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔐 FIRST INSTALL
    if (!_hasPin) {
      return SetPinPage(
        onCompleted: () {
          if (!mounted) return;

          setState(() {
            _hasPin = true;
            _unlocked = true;
          });
        },
      );
    }

    // 🔒 LOCK SCREEN
    if (!_unlocked) {
      return LockScreenPage(
        onUnlocked: () {
          setState(() {
            _unlocked = true;
          });
        },
        onPanicWipe: () async {
          if (!mounted) return;

          await _performSecureWipe();

          if (!mounted) return;

          setState(() {
            _hasPin = false;
            _unlocked = false;
          });
        },
      );
    }

    return const NotesListPage();
  }

  Future<void> _performSecureWipe() async {
    try {
      // 1️⃣ Clear session key
      SessionKeyManager.clear();

      // 2️⃣ Tutup SEMUA box
      await Hive.close();

      // 3️⃣ Hapus file fisik
      await Hive.deleteBoxFromDisk('notesBox');
      await Hive.deleteBoxFromDisk('securityBox');

      // 4️⃣ Hapus PIN
      await _lockService.clearPin();
    } catch (e) {
      debugPrint("SECURE WIPE ERROR: $e");
    }
  }
}
