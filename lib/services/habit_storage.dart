import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitStorage {
  static final _box = Hive.box<Habit>('habits');

  // ================= CRUD =================

  static List<Habit> active() {
    return _box.values.where((h) => !h.isArchived).toList();
  }

  static List<Habit> trash() {
    return _box.values.where((h) => h.isArchived).toList();
  }

  static Future save(Habit h) async {
    await _box.put(h.id, h);
  }

  static Future archive(Habit h) async {
    h.isArchived = true;
    await h.save();
  }

  static Future restore(Habit h) async {
    h.isArchived = false;
    await h.save();
  }

  static Future delete(Habit h) async {
    await h.delete();
  }

  // ================= DATE SYSTEM (SINGLE SOURCE) =================

  static String _today() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  static bool isDoneToday(Habit h) {
    return h.completedDates.contains(_today());
  }

  static Future toggleToday(Habit h) async {
    final today = _today();

    if (h.completedDates.contains(today)) {
      h.completedDates.remove(today);
    } else {
      h.completedDates.add(today);
    }

    await h.save();
  }

  // ================= STATS =================

  static int total(Habit h) {
    return h.completedDates.length;
  }

  static int streak(Habit h) {
    final list = _sorted(h);

    int s = 0;
    DateTime? prev;

    for (final d in list) {
      if (prev == null || prev.difference(d).inDays == 1) {
        s++;
      } else {
        break;
      }
      prev = d;
    }

    return s;
  }

  static int best(Habit h) {
    final list = _sorted(h);

    int best = 0;
    int cur = 0;
    DateTime? prev;

    for (final d in list) {
      if (prev == null || prev.difference(d).inDays == 1) {
        cur++;
      } else {
        cur = 1;
      }

      if (cur > best) best = cur;
      prev = d;
    }

    return best;
  }

  static double consistencyRate(Habit h) {
    if (h.completedDates.isEmpty) return 0;

    final sorted = _sorted(h);
    if (sorted.isEmpty) return 0;

    final start = sorted.last;
    final days = DateTime.now().difference(start).inDays + 1;

    return (h.completedDates.length / days).clamp(0.0, 1.0);
  }

  // ================= HELPERS =================

  static List<DateTime> _sorted(Habit h) {
    final list = h.completedDates
        .map((d) {
          try {
            return DateTime.parse(d);
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .toList();

    list.sort((a, b) => b.compareTo(a));

    return list;
  }
}
