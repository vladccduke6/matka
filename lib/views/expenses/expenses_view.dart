import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/buddy.dart';
import '../../models/expense.dart';
import '../../providers/buddy_providers.dart';
import '../../providers/expense_providers.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key, required this.journeyId});

  final String journeyId;

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  static const List<String> _currencyOptions = ['₹', '$', '€'];

  Future<void> _addExpense(List<Buddy> buddies) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final customPayerController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedCurrency = _currencyOptions.first;
    String? selectedPayerId = buddies.isNotEmpty ? buddies.first.id : null;
    final selectedShared = <String>{if (buddies.isNotEmpty) ...buddies.map((b) => b.id)};

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(selectedDate.year - 5),
                  lastDate: DateTime(selectedDate.year + 5),
                );
                if (picked != null) {
                  setSheetState(() => selectedDate = picked);
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCurrency,
                            items: _currencyOptions
                                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (value) => setSheetState(() {
                              if (value != null) selectedCurrency = value;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.event_outlined),
                      label: Text('Date: ${selectedDate.toLocal().toString().split(' ').first}'),
                    ),
                    const SizedBox(height: 12),
                    if (buddies.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedPayerId,
                        items: buddies
                            .map((b) => DropdownMenuItem<String>(value: b.id, child: Text(b.name)))
                            .toList(),
                        onChanged: (value) => setSheetState(() => selectedPayerId = value),
                        decoration: const InputDecoration(
                          labelText: 'Paid by',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      TextField(
                        controller: customPayerController,
                        decoration: const InputDecoration(
                          labelText: 'Paid by (name)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (buddies.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shared with'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final buddy in buddies)
                                FilterChip(
                                  label: Text(buddy.name),
                                  selected: selectedShared.contains(buddy.id),
                                  onSelected: (value) => setSheetState(() {
                                    if (value) {
                                      selectedShared.add(buddy.id);
                                    } else {
                                      selectedShared.remove(buddy.id);
                                    }
                                  }),
                                ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Add expense'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (confirmed != true) return;
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and amount are required')),
      );
      return;
    }

    final payer = buddies.isNotEmpty
        ? (selectedPayerId ?? buddies.first.id)
        : customPayerController.text.trim();
    final sharedList = buddies.isNotEmpty
        ? (selectedShared.isEmpty ? [selectedPayerId ?? buddies.first.id] : selectedShared.toList())
        : [payer];

    await ref.read(expenseListProvider(widget.journeyId).notifier).add(
          title: title,
          amount: amount,
          currency: selectedCurrency,
          date: selectedDate,
          paidBy: payer,
          sharedWith: sharedList,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added')),
    );
  }

  Map<String, double> _totalsByCurrency(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals.update(expense.currency, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return totals;
  }

  Map<String, Map<String, double>> _sharesByCurrency(List<Expense> expenses) {
    final result = <String, Map<String, double>>{};
    for (final expense in expenses) {
      final participants = expense.sharedWith.isEmpty
          ? <String>[expense.paidBy]
          : expense.sharedWith;
      if (participants.isEmpty) continue;
      final share = expense.amount / participants.length;
      final map = result.putIfAbsent(expense.currency, () => <String, double>{});
      for (final participant in participants) {
        map.update(participant, (value) => value + share, ifAbsent: () => share);
      }
    }
    return result;
  }

  String _displayName(String idOrName, List<Buddy> buddies) {
    for (final buddy in buddies) {
      if (buddy.id == idOrName) return buddy.name;
    }
    return idOrName;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseListProvider(widget.journeyId));
    final buddies = ref.watch(buddiesForJourneyProvider(widget.journeyId));

    final totals = _totalsByCurrency(expenses);
    final shares = _sharesByCurrency(expenses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _addExpense(buddies),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add expense'),
            ),
            const Spacer(),
          ],
        ),
        if (totals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No expenses yet'),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Total spend: ${totals.entries.map((e) => '${e.key}${e.value.toStringAsFixed(2)}').join('  |  ')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (shares.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Per-buddy split', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  for (final entry in shares.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key}: ${entry.value.entries.map((e) => '${_displayName(e.key, buddies)} ${e.value.toStringAsFixed(2)}').join(', ')}',
                      ),
                    ),
                ],
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.title),
                subtitle: Text(
                  '${expense.currency}${expense.amount.toStringAsFixed(2)} • ${expense.date.toLocal().toString().split(' ').first}\nPaid by ${_displayName(expense.paidBy, buddies)}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(expenseListProvider(widget.journeyId).notifier).delete(expense.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense removed')),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
