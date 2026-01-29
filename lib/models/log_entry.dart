class LogEntry {
  final String id;
  final DateTime timestamp;
  final String mood;
  final String event;
  final List<String> attachments;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.event,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'event': event,
      'attachments': attachments,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id']?.toString() ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      mood: json['mood']?.toString() ?? '😊',
      event: json['event']?.toString() ?? '',
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : [],
    );
  }
}
