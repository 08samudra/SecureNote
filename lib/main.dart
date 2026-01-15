import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_samtech/core/security/lock_service.dart';
import 'package:note_samtech/features/security/presentation/lock_screen_page.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/data/note_model.dart';
import 'features/notes/presentation/pages/notes_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();

  // Register Adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(NoteModelAdapter());
  }

  // Open Box
  await Hive.openBox<NoteModel>('notesBox');

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

    setState(() {
      _checked = true;
      _unlocked = !hasPin;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final hasPin = await _lockService.hasPin();

      if (hasPin) {
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

    if (!_unlocked) {
      return LockScreenPage(
        onUnlocked: () {
          setState(() {
            _unlocked = true;
          });
        },
      );
    }

    return const NotesListPage();
  }
}
