import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'timetable_screen.dart';
import 'diary_auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= APPEARANCE =================

          const _SectionTitle("Appearance"),
          const SizedBox(height: 10),

          _card(
            child: SwitchListTile(
              value: themeProvider.isDark,
              activeColor: Colors.lightBlueAccent,
              secondary: const Icon(
                Icons.dark_mode,
                color: Colors.lightBlueAccent,
              ),
              title: const Text(
                "Dark Mode",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                "Toggle app theme",
                style: TextStyle(color: Colors.white70),
              ),
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),

          const SizedBox(height: 24),

          // ================= PRODUCTIVITY =================

          const _SectionTitle("Productivity"),
          const SizedBox(height: 10),

          _navTile(
            icon: Icons.schedule,
            title: "Timetable",
            subtitle: "Plan your daily routine",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TimetableScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _navTile(
            icon: Icons.book,
            title: "My Diary",
            subtitle: "Private journal",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiaryAuthScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ================= ABOUT =================

          const _SectionTitle("About"),
          const SizedBox(height: 10),

          _navTile(
            icon: Icons.info_outline,
            title: "About App",
            subtitle: "Habit Tracker v1.0",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Habit Tracker",
                applicationVersion: "1.0.0",
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= CARD WRAPPER =================

  static Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ================= NAV TILE =================

  static Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.15),
              ),
              child: Icon(
                icon,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SECTION TITLE =================

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
