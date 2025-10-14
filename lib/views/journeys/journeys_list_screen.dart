import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/journey.dart';
import 'package:matka/providers/journey_providers.dart';
import 'package:matka/views/journeys/add_journey_dialog.dart';
import 'package:matka/views/journeys/booking_list_view.dart';
import 'package:matka/providers/export_import_providers.dart';
import 'package:matka/views/journal/journal_view.dart';
import 'package:matka/views/expenses/expenses_view.dart';
import 'package:share_plus/share_plus.dart';

class JourneysListScreen extends ConsumerWidget {
  const JourneysListScreen({super.key});

  Future<void> _createJourney(BuildContext context, WidgetRef ref) async {
    final created = await AddJourneyDialog.show(context);
    if (created == true) {
      // Refresh list and show success
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await ref.read(journeyListProvider.notifier).refresh();
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Journey created')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeys = ref.watch(journeyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journeys')),
      body: journeys.isEmpty
          ? const Center(child: Text('No journeys yet'))
          : ListView.separated(
              itemCount: journeys.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final Journey j = journeys[index];
                final range = '${j.startDate.toLocal().toString().split(' ').first} — ${j.endDate.toLocal().toString().split(' ').first}';
                return ExpansionTile(
                  title: Text(j.title),
                  subtitle: Text(range),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // In a future update, implement AddBooking dialog.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Add booking coming soon')),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('New Booking'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final service = ref.read(exportImportServiceProvider);
                              final res = await service.exportJourney(j.id);
                              await Share.shareXFiles([XFile(res.jsonFile.path)], text: 'Journey: ${j.title}');
                              messenger.showSnackBar(const SnackBar(content: Text('Journey exported')));
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share Journey'),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await ref.read(journeyListProvider.notifier).delete(j.id);
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Journey deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    BookingListView(journeyId: j.id),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: JournalView(journeyId: j.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ExpensesView(journeyId: j.id),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createJourney(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Journey'),
      ),
    );
  }
}
