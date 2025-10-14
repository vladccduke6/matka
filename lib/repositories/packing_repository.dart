import 'package:matka/models/packing_item.dart';

class PackingRepository {
  final Map<String, List<PackingItem>> _byJourney = {};

  static const defaultCategories = <String>[
    'Clothes',
    'Toiletries',
    'Medicines',
    'Tech',
  ];

  List<PackingItem> getByJourney(String journeyId) {
    final list = _byJourney[journeyId] ?? const <PackingItem>[];
    return List<PackingItem>.unmodifiable(list);
  }

  Future<void> add(PackingItem item) async {
    final list = _byJourney.putIfAbsent(item.journeyId, () => <PackingItem>[]);
    list.add(item);
  }

  Future<void> delete(String journeyId, String id) async {
    final list = _byJourney[journeyId];
    if (list == null) return;
    list.removeWhere((e) => e.id == id);
  }

  Future<void> toggleChecked(String journeyId, String id, bool checked) async {
    final list = _byJourney[journeyId];
    if (list == null) return;
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(checked: checked);
    }
  }

  double totalWeight(String journeyId) {
    final list = _byJourney[journeyId] ?? const <PackingItem>[];
    return list.fold(0.0, (sum, e) => sum + e.totalWeight());
  }
}
