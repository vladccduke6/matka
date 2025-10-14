import 'dart:math';

import 'package:matka/models/place.dart';

class DayPlan {
  final DateTime date;
  final List<Place> places; // ordered

  const DayPlan({required this.date, required this.places});

  double totalDistanceKm() {
    if (places.length < 2) return 0;
    double total = 0;
    for (var i = 0; i < places.length - 1; i++) {
      total += _haversineKm(
        places[i].latitude,
        places[i].longitude,
        places[i + 1].latitude,
        places[i + 1].longitude,
      );
    }
    return total;
  }
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
          cos(_deg2rad(lat1)) *
              cos(_deg2rad(lat2)) *
              (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

double _deg2rad(double deg) => deg * (pi / 180.0);
