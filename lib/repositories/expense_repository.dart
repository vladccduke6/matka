import 'package:matka/models/expense.dart';

class ExpenseRepository {
  final Map<String, List<Expense>> _byJourney = {};

  List<Expense> getByJourney(String journeyId) {
    final list = List<Expense>.from(_byJourney[journeyId] ?? const []);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> add(Expense expense) async {
    final list = _byJourney.putIfAbsent(expense.journeyId, () => <Expense>[]);
    list.add(expense);
  }

  Future<void> update(Expense expense) async {
    final list = _byJourney[expense.journeyId];
    if (list == null) return;
    final index = list.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      list[index] = expense;
    }
  }

  Future<void> delete(String journeyId, String expenseId) async {
    final list = _byJourney[journeyId];
    if (list == null) return;
    list.removeWhere((e) => e.id == expenseId);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (final entry in _byJourney.entries) {
      map[entry.key] = entry.value.map((e) => e.toMap()).toList();
    }
    return map;
  }

  void hydrate(Map<String, dynamic> map) {
    _byJourney.clear();
    for (final entry in map.entries) {
      final journeyId = entry.key;
    final items = (entry.value as List<dynamic>)
      .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      _byJourney[journeyId] = items;
    }
  }
}
