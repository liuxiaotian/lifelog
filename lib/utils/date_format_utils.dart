import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateFormatUtils {
  static const String _timeFormatKey = 'time_format';
  
  /// Get the user's preferred time format setting
  static Future<String> getTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeFormatKey) ?? 'default';
  }
  
  /// Set the user's preferred time format
  static Future<void> setTimeFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, format);
  }
  
  /// Format a DateTime according to user preference (full datetime)
  static String formatDateTime(DateTime dateTime, String format) {
    if (format == 'numeric') {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    }
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
  
  /// Format a DateTime according to user preference (date only)
  static String formatDate(DateTime dateTime, String format) {
    if (format == 'numeric') {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
  
  /// Format time only
  static String formatTime(DateTime dateTime, String format) {
    if (format == 'numeric') {
      return DateFormat('HH:mm:ss').format(dateTime);
    }
    return DateFormat('HH:mm').format(dateTime);
  }
  
  /// Format short date (for timeline)
  static String formatShortDate(DateTime dateTime, String format) {
    if (format == 'numeric') {
      return DateFormat('MM-dd').format(dateTime);
    }
    return DateFormat('MMM dd').format(dateTime);
  }
}
