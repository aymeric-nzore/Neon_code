class Tip {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;
  final bool isFavorite;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.isFavorite = false,
  });

  Tip copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? date,
    bool? isFavorite,
  }) {
    return Tip(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      date: date ?? this.date,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Tip.fromMap(Map<String, dynamic> map, {bool isFav = false}) {
    return Tip(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Général',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      isFavorite: isFav,
    );
  }
}
