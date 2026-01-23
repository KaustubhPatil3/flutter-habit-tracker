import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

import 'timetable_screen.dart';
import 'diary_auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // ================= THEME =================

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: theme.isDark,
            onChanged: (_) {
              theme.toggleTheme();
            },
          ),

          const Divider(),

          /* ---------------- TIMETABLE ---------------- */

          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Timetable"),
            subtitle: const Text("Plan your daily routine"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TimetableScreen(),
                ),
              );
            },
          ),

          const Divider(),

          /* ---------------- DIARY ---------------- */

          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("My Diary"),
            subtitle: const Text("Private journal"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiaryAuthScreen(),
                ),
              );
            },
          ),

          const Divider(),

          /* ---------------- ABOUT ---------------- */

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            subtitle: const Text("Habit Tracker v1.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Habit Tracker",
                applicationVersion: "1.0.0",
              );
            },
          ),
        ],
      ),
    );
  }
}
