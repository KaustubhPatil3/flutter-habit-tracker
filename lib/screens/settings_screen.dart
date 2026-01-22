import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeService.isDark();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: dark,
            onChanged: (_) {
              ThemeService.toggle();
            },
          ),
        ],
      ),
    );
  }
}
