import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import 'diary_settings_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late Box box;

  final textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    box = Hive.box('diary');
  }

  List get entries => box.get("entries", defaultValue: []);

  // ================= SAVE =================

  Future<void> saveEntry({int? index}) async {
    if (textCtrl.text.isEmpty) return;

    final list = box.get("entries", defaultValue: []);

    final data = {
      "text": textCtrl.text,
      "date": DateTime.now().toString(),
    };

    if (index == null) {
      list.add(data);
    } else {
      list[index] = data;
    }

    await box.put("entries", list);

    textCtrl.clear();
    setState(() {});
  }

  // ================= DELETE =================

  Future<void> deleteEntry(int index) async {
    final list = box.get("entries");
    list.removeAt(index);

    await box.put("entries", list);
    setState(() {});
  }

  // ================= EDITOR =================

  void openEditor({int? index}) {
    if (index != null) {
      textCtrl.text = entries[index]["text"];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDF6E3),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                index == null ? "New Page" : "Edit Page",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                maxLines: 6,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "Dear Diary...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  onPressed: () {
                    saveEntry(index: index);
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  // ================= DETAILS =================

  void openDetails(Map entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryDetailScreen(entry: entry),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final list = entries.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text("My Diary"),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiarySettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.edit),
        onPressed: () => openEditor(),
      ),
      body: list.isEmpty
          ? const Center(
              child: Text(
                "No pages yet 📖",
                style: TextStyle(color: Colors.brown),
              ),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final entry = list[i];
                final realIndex = entries.length - 1 - i;

                return GestureDetector(
                  onTap: () => openDetails(entry),
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text("Edit"),
                                onTap: () {
                                  Navigator.pop(context);
                                  openEditor(index: realIndex);
                                },
                              ),
                              ListTile(
                                leading:
                                    const Icon(Icons.delete, color: Colors.red),
                                title: const Text("Delete"),
                                onTap: () {
                                  Navigator.pop(context);
                                  deleteEntry(realIndex);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat("dd MMM yyyy • hh:mm a")
                                .format(DateTime.parse(entry["date"])),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry["text"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ================= DETAILS PAGE =================

class DiaryDetailScreen extends StatelessWidget {
  final Map entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text("Diary Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat("dd MMM yyyy • hh:mm a")
                  .format(DateTime.parse(entry["date"])),
              style: const TextStyle(
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              entry["text"],
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
