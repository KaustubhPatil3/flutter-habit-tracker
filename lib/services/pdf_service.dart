import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';
import 'habit_storage.dart';

class PdfService {
  static Future<File> export(List<Habit> habits) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Habit Report",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              ...habits.map((h) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                    "${h.name}  |  Total: ${HabitStorage.total(h)}  |  Streak: ${HabitStorage.streak(h)}",
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/habits_report.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
