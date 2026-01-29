class LogEntry {
  final String id;
  final DateTime timestamp;
  final String mood;
  final String event;
  final List<String> attachments;
  final int? feelingScore; // 1-10 scale, optional
  final bool isEpitaph; // Flag to identify epitaph entries
  final bool isWriteToFuture; // Flag for future letters
  final DateTime? unlockDate; // Date when future letter can be viewed
  final double? latitude; // Location latitude
  final double? longitude; // Location longitude
  final String? locationName; // Human-readable location name
  final bool isHighlight; // Flag to mark highlight moments

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.event,
    this.attachments = const [],
    this.feelingScore,
    this.isEpitaph = false,
    this.isWriteToFuture = false,
    this.unlockDate,
    this.latitude,
    this.longitude,
    this.locationName,
    this.isHighlight = false,
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
      'isWriteToFuture': isWriteToFuture,
      'unlockDate': unlockDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isHighlight': isHighlight,
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
      isWriteToFuture: json['isWriteToFuture'] as bool? ?? false,
      unlockDate: json['unlockDate'] != null 
          ? DateTime.parse(json['unlockDate']) 
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      isHighlight: json['isHighlight'] as bool? ?? false,
    );
  }
}
