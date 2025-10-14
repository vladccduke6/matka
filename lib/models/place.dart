class Place {
  final String id;
  final String journeyId;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final int estimatedVisitMinutes;
  final bool completed;

  const Place({
    required this.id,
    required this.journeyId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.estimatedVisitMinutes,
    required this.completed,
  });

  Place copyWith({
    String? id,
    String? journeyId,
    String? name,
    double? latitude,
    double? longitude,
    String? category,
    int? estimatedVisitMinutes,
    bool? completed,
  }) => Place(
        id: id ?? this.id,
        journeyId: journeyId ?? this.journeyId,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        category: category ?? this.category,
        estimatedVisitMinutes:
            estimatedVisitMinutes ?? this.estimatedVisitMinutes,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'journeyId': journeyId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'estimatedVisitMinutes': estimatedVisitMinutes,
        'completed': completed,
      };

  factory Place.fromMap(Map<String, dynamic> map) => Place(
        id: map['id'] as String,
        journeyId: map['journeyId'] as String,
        name: map['name'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        category: map['category'] as String,
        estimatedVisitMinutes: map['estimatedVisitMinutes'] as int,
        completed: map['completed'] as bool,
      );
}
