import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/log_entry.dart';

class StorageService {
  static const String _storageKey = 'log_entries';

  Future<List<LogEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_storageKey);
    
    if (entriesJson == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(entriesJson);
    return decoded.map((e) => LogEntry.fromJson(e)).toList();
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
}
