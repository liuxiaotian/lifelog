import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/log_entry.dart';

class StorageService {
  static const String _storageKey = 'log_entries';
  static const String _epitaphEnabledKey = 'epitaph_enabled';
  static const String _epitaphBirthdayKey = 'epitaph_birthday';
  static const String _epitaphLifespanKey = 'epitaph_lifespan';
  static const String _epitaphContentKey = 'epitaph_content';

  Future<List<LogEntry>> getEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_storageKey);
      
      if (entriesJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(entriesJson);
      return decoded.map((e) => LogEntry.fromJson(e)).toList();
    } catch (e) {
      // If there's any error reading or parsing the data, return empty list
      // This prevents crashes from corrupted data
      return [];
    }
  }

  Future<void> saveEntries(List<LogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addEntry(LogEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    await saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await saveEntries(entries);
  }

  Future<void> clearAllEntries() async {
    await saveEntries([]);
  }

  // Epitaph settings
  Future<bool> isEpitaphEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_epitaphEnabledKey) ?? false;
  }

  Future<void> setEpitaphEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_epitaphEnabledKey, enabled);
  }

  Future<DateTime?> getEpitaphBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    final birthdayStr = prefs.getString(_epitaphBirthdayKey);
    if (birthdayStr != null) {
      return DateTime.parse(birthdayStr);
    }
    return null;
  }

  Future<void> setEpitaphBirthday(DateTime? birthday) async {
    final prefs = await SharedPreferences.getInstance();
    if (birthday != null) {
      await prefs.setString(_epitaphBirthdayKey, birthday.toIso8601String());
    } else {
      await prefs.remove(_epitaphBirthdayKey);
    }
  }

  Future<int?> getEpitaphLifespan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_epitaphLifespanKey);
  }

  Future<void> setEpitaphLifespan(int? lifespan) async {
    final prefs = await SharedPreferences.getInstance();
    if (lifespan != null) {
      await prefs.setInt(_epitaphLifespanKey, lifespan);
    } else {
      await prefs.remove(_epitaphLifespanKey);
    }
  }

  Future<String?> getEpitaphContent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_epitaphContentKey);
  }

  Future<void> setEpitaphContent(String? content) async {
    final prefs = await SharedPreferences.getInstance();
    if (content != null && content.isNotEmpty) {
      await prefs.setString(_epitaphContentKey, content);
    } else {
      await prefs.remove(_epitaphContentKey);
    }
  }
}
