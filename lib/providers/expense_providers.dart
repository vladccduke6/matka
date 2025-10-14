import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/expense.dart';
import 'package:matka/repositories/expense_repository.dart';

import 'journey_providers.dart' show uuidProvider;

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expenseListProvider = StateNotifierProvider.family<ExpenseListNotifier, List<Expense>, String>((ref, journeyId) {
  final repo = ref.watch(expenseRepositoryProvider);
  final uuid = ref.watch(uuidProvider);
  return ExpenseListNotifier(repo, uuid.v4, journeyId);
});

class ExpenseListNotifier extends StateNotifier<List<Expense>> {
  ExpenseListNotifier(this._repository, this._idFactory, this.journeyId) : super(const []) {
    _load();
  }

  final ExpenseRepository _repository;
  final String Function() _idFactory;
  final String journeyId;

  Future<void> _load() async {
    state = _repository.getByJourney(journeyId);
  }

  Future<void> add({
    required String title,
    required double amount,
    required String currency,
    required DateTime date,
    required String paidBy,
    required List<String> sharedWith,
  }) async {
    final expense = Expense(
      id: _idFactory(),
      journeyId: journeyId,
      title: title,
      amount: amount,
      currency: currency,
      date: date,
      paidBy: paidBy,
      sharedWith: List<String>.from(sharedWith),
    );
    await _repository.add(expense);
    await refresh();
  }

  Future<void> delete(String expenseId) async {
    await _repository.delete(journeyId, expenseId);
    await refresh();
  }

  Future<void> refresh() async {
    state = _repository.getByJourney(journeyId);
  }
}
