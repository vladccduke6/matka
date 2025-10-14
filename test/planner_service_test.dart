import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:matka/core/planner/planner_service.dart';
import 'package:matka/models/day_plan.dart';
import 'package:matka/models/place.dart';

void main() {
  group('PlannerService', () {
    test('nearest-neighbor is within 40% of optimal on small set', () {
      final rand = Random(42);
      const centerLat = 37.7749; // SF area
      const centerLon = -122.4194;

      final places = List<Place>.generate(7, (i) {
        final lat = centerLat + (rand.nextDouble() - 0.5) * 0.1;
        final lon = centerLon + (rand.nextDouble() - 0.5) * 0.1;
        return Place(
          id: 'p$i',
          journeyId: 'j1',
          name: 'P$i',
          latitude: lat,
          longitude: lon,
          category: 'poi',
          estimatedVisitMinutes: 60,
          completed: false,
        );
      });

      final planner = PlannerService();
      final day = DateTime(2024, 1, 1);
      final plans = planner.planTrip(
        places: places,
        startDate: day,
        endDate: day,
        dailyHours: 24,
      );
      expect(plans.length, 1);
      final planned = plans.first;
      final plannedDistance = planned.totalDistanceKm();

      // Compute optimal (brute force) for small N
      final optimalDistance = _bruteForceOptimalDistance(places);

      // Heuristic should be reasonably close to optimal
      expect(plannedDistance, lessThanOrEqualTo(optimalDistance * 1.4));
    });
  });
}

double _bruteForceOptimalDistance(List<Place> places) {
  final list = [...places];
  double best = double.infinity;
  void permute(int l) {
    if (l == list.length) {
      final d = DayPlan(date: DateTime(0), places: List.of(list)).totalDistanceKm();
      if (d < best) best = d;
      return;
    }
    for (int i = l; i < list.length; i++) {
      _swap(list, l, i);
      permute(l + 1);
      _swap(list, l, i);
    }
  }

  permute(0);
  return best;
}

void _swap(List list, int i, int j) {
  final tmp = list[i];
  list[i] = list[j];
  list[j] = tmp;
}
