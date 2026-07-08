class AgriculturalAlert {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String level; // 'CRITICAL', 'WARNING', 'INFO'
  final String action;
  bool isRead;

  AgriculturalAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.level,
    required this.action,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'action': action,
      'isRead': isRead,
    };
  }

  factory AgriculturalAlert.fromMap(Map<String, dynamic> map) {
    return AgriculturalAlert(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      level: map['level'],
      action: map['action'],
      isRead: map['isRead'] ?? false,
    );
  }
}
