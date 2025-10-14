import 'package:flutter/foundation.dart';

@immutable
class JournalEntry {
  final String id;
  final String journeyId;
  final String text;
  final List<String> imagePaths;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.journeyId,
    required this.text,
    required this.imagePaths,
    required this.createdAt,
  });

  JournalEntry copyWith({
    String? id,
    String? journeyId,
    String? text,
    List<String>? imagePaths,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      journeyId: journeyId ?? this.journeyId,
      text: text ?? this.text,
      imagePaths: imagePaths ?? List<String>.from(this.imagePaths),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journeyId': journeyId,
      'text': text,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      journeyId: map['journeyId'] as String,
      text: map['text'] as String,
      imagePaths: (map['imagePaths'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
