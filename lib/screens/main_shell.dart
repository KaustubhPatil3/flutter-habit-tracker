import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/theme_provider.dart';

// Main Screens
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

// Extra Screens
import 'report_screen.dart';
import 'trends_screen.dart';
import 'trash_screen.dart';
import 'achievements_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<Habit>('habits').listenable(),
      builder: (context, Box<Habit> box, _) {
        final habits = box.values.toList();

        // ================= ALL MAIN TABS =================

        final List<Widget> screens = [
          const HomeScreen(),
          CalendarScreen(habits: habits),
          const StatsScreen(),
          const ReportScreen(),
          TrendsScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          // ================= APP BAR =================

          appBar: AppBar(
            title: const Text("Habit Tracker"),
            actions: [
              // Theme Toggle
              IconButton(
                icon: Icon(
                  theme.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  theme.toggleTheme();
                },
              ),

              // More Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'trash') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrashScreen(),
                      ),
                    );
                  }

                  if (value == 'achievements') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'trash',
                    child: Text("Trash"),
                  ),
                  PopupMenuItem(
                    value: 'achievements',
                    child: Text("Achievements"),
                  ),
                ],
              ),
            ],
          ),

          // ================= BODY =================

          body: IndexedStack(
            index: _index,
            children: screens,
          ),

          // ================= BOTTOM NAV =================

          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
              setState(() {
                _index = i;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month),
                label: "Calendar",
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart),
                label: "Stats",
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long),
                label: "Reports",
              ),
              NavigationDestination(
                icon: Icon(Icons.trending_up),
                label: "Trends",
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
        );
      },
    );
  }
}
