class LogEntry {
  final String id;
  final DateTime timestamp;
  final String mood;
  final String event;
  final List<String> attachments;
  final int? feelingScore; // 1-10 scale, optional
  final bool isEpitaph; // Flag to identify epitaph entries

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.event,
    this.attachments = const [],
    this.feelingScore,
    this.isEpitaph = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'event': event,
      'attachments': attachments,
      'feelingScore': feelingScore,
      'isEpitaph': isEpitaph,
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
      feelingScore: json['feelingScore'] as int?,
      isEpitaph: json['isEpitaph'] as bool? ?? false,
    );
  }
}
