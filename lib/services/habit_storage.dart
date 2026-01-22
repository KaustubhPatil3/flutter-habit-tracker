import 'package:hive/hive.dart';

import '../models/habit.dart';

class HabitStorage {
  static final _box = Hive.box<Habit>('habits');

  static Future update(Habit h, String newName) async {
    h.name = newName;
    await h.save();
  }

  // ================= CRUD =================

  static List<Habit> active() =>
      _box.values.where((e) => !e.isArchived).toList();

  static List<Habit> trash() => _box.values.where((e) => e.isArchived).toList();

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

  // ================= TRACKING =================

  static void toggleToday(Habit h) {
    final today = _today();

    if (h.completedDates.contains(today)) {
      h.completedDates.remove(today);
    } else {
      h.completedDates.add(today);
    }

    h.save();
  }

  // ================= STATS =================

  static int total(Habit h) => h.completedDates.length;

  static int streak(Habit h) {
    final d = _sorted(h);

    int s = 0;
    DateTime? prev;

    for (final x in d) {
      if (prev == null || prev!.difference(x).inDays == 1) {
        s++;
      } else {
        break;
      }

      prev = x;
    }

    return s;
  }

  static int best(Habit h) {
    final d = _sorted(h);

    int best = 0, cur = 0;
    DateTime? prev;

    for (final x in d) {
      if (prev == null || prev!.difference(x).inDays == 1) {
        cur++;
      } else {
        cur = 1;
      }

      best = cur > best ? cur : best;
      prev = x;
    }

    return best;
  }

  static double rate(Habit h) {
    if (h.completedDates.isEmpty) return 0;

    final start = DateTime.parse(h.completedDates.first);

    final days = DateTime.now().difference(start).inDays + 1;

    return h.completedDates.length / days;
  }

  // ================= GRAPH =================

  static Map<String, int> monthly(Habit h) {
    final map = <String, int>{};

    for (final d in h.completedDates) {
      if (d.length >= 7) {
        final m = d.substring(0, 7); // yyyy-MM
        map[m] = (map[m] ?? 0) + 1;
      }
    }

    return map;
  }

  // ================= HELPERS =================

  static String _today() {
    final now = DateTime.now();

    return "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

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
