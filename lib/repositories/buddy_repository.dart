import 'package:matka/models/buddy.dart';

class BuddyRepository {
  final List<Buddy> _buddies = [];
  final Map<String, Set<String>> _journeyBuddies = {}; // journeyId -> buddyIds

  List<Buddy> all() => List.unmodifiable(_buddies);

  Future<void> addBuddy(Buddy b) async {
    _buddies.add(b);
  }

  Future<void> removeBuddy(String id) async {
    _buddies.removeWhere((e) => e.id == id);
    for (final set in _journeyBuddies.values) {
      set.remove(id);
    }
  }

  List<Buddy> forJourney(String journeyId) {
    final set = _journeyBuddies[journeyId] ?? const <String>{};
    return _buddies.where((b) => set.contains(b.id)).toList(growable: false);
  }

  Future<void> attachToJourney(String journeyId, String buddyId) async {
    final set = _journeyBuddies.putIfAbsent(journeyId, () => <String>{});
    set.add(buddyId);
  }

  Future<void> detachFromJourney(String journeyId, String buddyId) async {
    final set = _journeyBuddies[journeyId];
    set?.remove(buddyId);
  }
}
