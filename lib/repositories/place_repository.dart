import 'package:matka/models/place.dart';

class PlaceRepository {
  final List<Place> _items = [];

  List<Place> getByJourney(String journeyId) {
    final list = _items.where((p) => p.journeyId == journeyId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(list);
  }

  Future<void> add(Place place) async {
    _items.add(place);
  }

  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }

  Future<void> update(Place updated) async {
    final idx = _items.indexWhere((p) => p.id == updated.id);
    if (idx != -1) _items[idx] = updated;
  }
}
