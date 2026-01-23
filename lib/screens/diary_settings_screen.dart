import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiarySettingsScreen extends StatefulWidget {
  const DiarySettingsScreen({super.key});

  @override
  State<DiarySettingsScreen> createState() => _DiarySettingsScreenState();
}

class _DiarySettingsScreenState extends State<DiarySettingsScreen> {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();

  String savedPin = "1234";

  @override
  void initState() {
    super.initState();
    loadPin();
  }

  void loadPin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      savedPin = prefs.getString("diary_pin") ?? "1234";
    });
  }

  Future<void> changePin() async {
    final prefs = await SharedPreferences.getInstance();

    if (oldCtrl.text != savedPin) {
      showMsg("Wrong old password");
      return;
    }

    if (newCtrl.text.length < 4) {
      showMsg("Min 4 digits required");
      return;
    }

    await prefs.setString("diary_pin", newCtrl.text);

    showMsg("Password changed");

    oldCtrl.clear();
    newCtrl.clear();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diary Security")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: changePin,
                child: const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
