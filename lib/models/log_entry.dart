class LogEntry {
  final String id;
  final DateTime timestamp;
  final String mood;
  final String event;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.event,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'event': event,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      mood: json['mood'],
      event: json['event'],
    );
  }
}
