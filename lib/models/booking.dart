enum BookingType { train, flight, hotel }

class Booking {
  final String id;
  final String journeyId;
  final BookingType type;
  final String provider; // airline/hotel/train provider
  final DateTime startDate;
  final DateTime endDate;
  final String details;
  final String? ticketImagePath;

  const Booking({
    required this.id,
    required this.journeyId,
    required this.type,
    required this.provider,
    required this.startDate,
    required this.endDate,
    required this.details,
    this.ticketImagePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'journeyId': journeyId,
        'type': type.name,
        'provider': provider,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'details': details,
        'ticketImagePath': ticketImagePath,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] as String,
        journeyId: map['journeyId'] as String,
        type: BookingType.values.firstWhere((e) => e.name == map['type'] as String),
        provider: map['provider'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        details: map['details'] as String,
        ticketImagePath: map['ticketImagePath'] as String?,
      );
}
