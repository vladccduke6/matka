import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/packing_item.dart';
import 'package:matka/repositories/packing_repository.dart';
import 'package:uuid/uuid.dart';

final packingRepoProvider = Provider<PackingRepository>((ref) => PackingRepository());
final _uuidProvider = Provider<Uuid>((ref) => const Uuid());

final packingItemsProvider = StateNotifierProvider.family<_PackingNotifier, List<PackingItem>, String>(
  (ref, journeyId) => _PackingNotifier(ref.watch(packingRepoProvider), journeyId),
);

class _PackingNotifier extends StateNotifier<List<PackingItem>> {
  _PackingNotifier(this._repo, this.journeyId) : super(const []);

  final PackingRepository _repo;
  final String journeyId;

  Future<void> refresh() async {
    state = _repo.getByJourney(journeyId);
  }

  Future<void> add({
    required String name,
    required String category,
    int quantity = 1,
    double weight = 0.0,
    required String Function() genId,
  }) async {
    final item = PackingItem(
      id: genId(),
      journeyId: journeyId,
      name: name,
      category: category,
      quantity: quantity,
      weight: weight,
      checked: false,
    );
    await _repo.add(item);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(journeyId, id);
    await refresh();
  }

  Future<void> toggle(String id, bool checked) async {
    await _repo.toggleChecked(journeyId, id, checked);
    await refresh();
  }

  double totalWeight() => _repo.totalWeight(journeyId);
}

class PackingListView extends ConsumerWidget {
  const PackingListView({super.key, required this.journeyId});

  final String journeyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(packingItemsProvider(journeyId));
    final categories = PackingRepository.defaultCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddItemRow(journeyId: journeyId),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No packing items'))
              : ListView(
                  children: [
                    for (final cat in categories)
                      _CategorySection(
                        title: cat,
                        items: items.where((e) => e.category == cat).toList(),
                        journeyId: journeyId,
                      ),
                    if (items.any((e) => !categories.contains(e.category)))
                      _CategorySection(
                        title: 'Other',
                        items: items.where((e) => !categories.contains(e.category)).toList(),
                        journeyId: journeyId,
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Total weight: ${ref.watch(packingItemsProvider(journeyId).notifier).totalWeight().toStringAsFixed(2)} kg',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({required this.title, required this.items, required this.journeyId});

  final String title;
  final List<PackingItem> items;
  final String journeyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true,
      children: [
        for (final item in items)
          CheckboxListTile(
            value: item.checked,
            onChanged: (v) => ref.read(packingItemsProvider(journeyId).notifier).toggle(item.id, v ?? false),
            title: Text('${item.name} ×${item.quantity}'),
            subtitle: Text('${item.totalWeight().toStringAsFixed(2)} kg'),
            secondary: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(packingItemsProvider(journeyId).notifier).delete(item.id),
            ),
          ),
      ],
    );
  }
}

class _AddItemRow extends ConsumerStatefulWidget {
  const _AddItemRow({required this.journeyId});
  final String journeyId;

  @override
  ConsumerState<_AddItemRow> createState() => _AddItemRowState();
}

class _AddItemRowState extends ConsumerState<_AddItemRow> {
  final _nameCtrl = TextEditingController();
  String _category = PackingRepository.defaultCategories.first;
  int _quantity = 1;
  double _weight = 0.0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _category,
            items: [
              for (final c in PackingRepository.defaultCategories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _quantity = int.tryParse(v) ?? 1),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _weight = double.tryParse(v) ?? 0.0),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              if (_nameCtrl.text.trim().isEmpty) return;
              final genId = ref.read(_uuidProvider).v4;
              await ref
                  .read(packingItemsProvider(widget.journeyId).notifier)
                  .add(name: _nameCtrl.text.trim(), category: _category, quantity: _quantity, weight: _weight, genId: genId);
              setState(() {
                _nameCtrl.clear();
                _quantity = 1;
                _weight = 0.0;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
