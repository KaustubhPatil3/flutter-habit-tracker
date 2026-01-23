import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diary_screen.dart';

class DiaryAuthScreen extends StatefulWidget {
  const DiaryAuthScreen({super.key});

  @override
  State<DiaryAuthScreen> createState() => _DiaryAuthScreenState();
}

class _DiaryAuthScreenState extends State<DiaryAuthScreen> {
  final pinController = TextEditingController();

  bool isLoading = false;
  String savedPin = "1234";

  @override
  void initState() {
    super.initState();
    loadPin();
  }

  // Load saved password
  void loadPin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      savedPin = prefs.getString("diary_pin") ?? "1234";
    });
  }

  // Verify password
  Future<void> verifyPin() async {
    if (pinController.text.isEmpty) {
      showMsg("Enter password");
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (pinController.text == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DiaryScreen(),
        ),
      );
    } else {
      showMsg("Wrong password ❌");
    }

    setState(() => isLoading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text("Diary Lock"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.brown,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter Your Diary Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                    ),
                    onPressed: isLoading ? null : verifyPin,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Unlock Diary",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
