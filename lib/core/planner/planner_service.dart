import 'dart:math';

import 'package:matka/models/day_plan.dart';
import 'package:matka/models/place.dart';

class PlannerService {
  List<DayPlan> planTrip({
    required List<Place> places,
    required DateTime startDate,
    required DateTime endDate,
    required int dailyHours,
  }) {
    if (places.isEmpty) return _emptyDays(startDate, endDate);

    final days = endDate.difference(startDate).inDays + 1;
    final k = max(1, days);

    final clusters = _kMeans(places, k);

    final flattened = clusters.expand((c) => c).toList();
    final balanced = List.generate(k, (_) => <Place>[]);
    for (var i = 0; i < flattened.length; i++) {
      balanced[i % k].add(flattened[i]);
    }

    final plans = <DayPlan>[];
    for (var i = 0; i < k; i++) {
      final date = startDate.add(Duration(days: i));
      final maxPerDay = max(1, dailyHours);
      final dayPlaces = balanced[i].length > maxPerDay
          ? balanced[i].sublist(0, maxPerDay)
          : balanced[i];
      final ordered = _nearestNeighborOrder(dayPlaces);
      plans.add(DayPlan(date: date, places: ordered));
    }

    return plans;
  }

  List<DayPlan> _emptyDays(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) => DayPlan(date: start.add(Duration(days: i)), places: const []));
  }

  List<List<Place>> _kMeans(List<Place> places, int k, {int iterations = 10}) {
    final sorted = [...places]..sort((a, b) => a.id.compareTo(b.id));
    final centroids = <Point<double>>[];
    for (var i = 0; i < k; i++) {
      final p = sorted[i % sorted.length];
      centroids.add(Point(p.latitude, p.longitude));
    }

    var clusters = List.generate(k, (_) => <Place>[]);
    for (var iter = 0; iter < iterations; iter++) {
      clusters = List.generate(k, (_) => <Place>[]);
      for (final p in places) {
        var best = 0;
        var bestDist = double.infinity;
        for (var c = 0; c < k; c++) {
          final d = _geoDistanceKm(Point(p.latitude, p.longitude), centroids[c]);
          if (d < bestDist) {
            bestDist = d;
            best = c;
          }
        }
        clusters[best].add(p);
      }
      for (var c = 0; c < k; c++) {
        if (clusters[c].isEmpty) continue;
        final lat = clusters[c].map((e) => e.latitude).reduce((a, b) => a + b) / clusters[c].length;
        final lon = clusters[c].map((e) => e.longitude).reduce((a, b) => a + b) / clusters[c].length;
        centroids[c] = Point(lat, lon);
      }
    }
    return clusters;
  }

  List<Place> _nearestNeighborOrder(List<Place> places) {
    if (places.length <= 2) return [...places];
    final unvisited = [...places];
    unvisited.sort((a, b) => b.latitude.compareTo(a.latitude));
    final route = <Place>[];
    var current = unvisited.removeAt(0);
    route.add(current);
    while (unvisited.isNotEmpty) {
      var bestIdx = 0;
      var bestDist = double.infinity;
      for (var i = 0; i < unvisited.length; i++) {
        final d = _haversineKm(
          current.latitude,
          current.longitude,
          unvisited[i].latitude,
          unvisited[i].longitude,
        );
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }
      current = unvisited.removeAt(bestIdx);
      route.add(current);
    }
    return route;
  }

  double _geoDistanceKm(Point<double> a, Point<double> b) => _haversineKm(a.x, a.y, b.x, b.y);
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

double _deg2rad(double deg) => deg * (pi / 180.0);