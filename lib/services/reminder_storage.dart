import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine_reminder.dart';

class ReminderStorage {
  static const _remindersKey = 'med_reminders_v2';
  static const _nextIdKey = 'med_reminders_next_id_v2';

  static Future<List<MedicineReminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => MedicineReminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> save(List<MedicineReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(reminders.map((e) => e.toJson()).toList());
    await prefs.setString(_remindersKey, raw);
  }

  static Future<int> nextId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_nextIdKey) ?? 1;
    await prefs.setInt(_nextIdKey, current + 1);
    return current;
  }
}
