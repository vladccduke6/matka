class Journey {
  final String id; // UUID
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const Journey({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Journey copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Journey(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Journey.fromMap(Map<String, dynamic> map) {
    return Journey(
      id: map['id'] as String,
      title: map['title'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Journey &&
        other.id == id &&
        other.title == title &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, startDate, endDate, createdAt);

  @override
  String toString() => 'Journey(id: $id, title: $title)';
}
