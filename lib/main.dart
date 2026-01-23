import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/habit.dart';

import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();

  // REGISTER ADAPTER
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }

  // OPEN BOX
  await Hive.openBox<Habit>('habits');
  await Hive.openBox('diary'); // ✅ ADD THIS

  await Hive.openBox('timetable'); // IMPORTANT

  // INIT NOTIFICATIONS
  await NotificationService.init();

  runApp(const MyApp());
}

// ================= APP ROOT =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'Habit Tracker',

            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,

            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,

            home: const MainShell(), // ✅ MUST BE MainShell
          );
        },
      ),
    );
  }
}
