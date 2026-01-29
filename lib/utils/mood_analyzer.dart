import '../models/log_entry.dart';

class MoodAnalyzer {
  /// Checks if the last 3 entries have feeling scores below 5
  /// Returns true if low mood pattern is detected
  static bool hasLowMoodPattern(List<LogEntry> entries) {
    // Filter entries that have feeling scores
    final entriesWithScores = entries
        .where((e) => e.feelingScore != null)
        .toList();
    
    if (entriesWithScores.length < 3) {
      return false;
    }

    // Check the 3 most recent entries with scores
    final recentThree = entriesWithScores.take(3).toList();
    
    return recentThree.every((entry) => entry.feelingScore! < 5);
  }

  /// Gets highlight entries (feeling score >= 8)
  static List<LogEntry> getHighlightEntries(List<LogEntry> entries) {
    return entries
        .where((e) => e.feelingScore != null && e.feelingScore! >= 8)
        .toList();
  }
}
