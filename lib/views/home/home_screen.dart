import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/journey.dart';
import 'package:matka/providers/journey_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    Future<void> pickStart() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null) startDate = picked;
    }

    Future<void> pickEnd() async {
      final base = startDate ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: base,
        firstDate: base,
        lastDate: DateTime(base.year + 5),
      );
      if (picked != null) endDate = picked;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Journey'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: pickStart,
                        child: Text(startDate == null
                            ? 'Pick start date'
                            : 'Start: ${startDate!.toLocal().toString().split(' ').first}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: pickEnd,
                        child: Text(endDate == null
                            ? 'Pick end date'
                            : 'End: ${endDate!.toLocal().toString().split(' ').first}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty || startDate == null || endDate == null) {
                  return;
                }
                final uuid = ref.read(uuidProvider);
                // Close dialog first to avoid using BuildContext across async gap
                Navigator.of(ctx).pop();
                await ref.read(journeyListProvider.notifier).add(
                      title: title,
                      start: startDate!,
                      end: endDate!,
                      createdAt: DateTime.now(),
                      genId: () => uuid.v4(),
                    );
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeys = ref.watch(journeyListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Matka')),
      body: journeys.isEmpty
          ? const Center(child: Text('No journeys yet'))
          : ListView.separated(
              itemCount: journeys.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final Journey j = journeys[index];
                return ListTile(
                  title: Text(j.title),
                  subtitle: Text(
                    '${j.startDate.toLocal().toString().split(' ').first} → ${j.endDate.toLocal().toString().split(' ').first}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(journeyListProvider.notifier).delete(j.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
