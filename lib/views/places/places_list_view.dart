import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/place.dart';
import 'package:matka/repositories/place_repository.dart';
import 'package:matka/providers/place_providers.dart';
import 'package:uuid/uuid.dart';

final _uuidProvider = Provider<Uuid>((ref) => const Uuid());
final placesProvider =
    StateNotifierProvider.family<_PlacesNotifier, List<Place>, String>(
        (ref, journeyId) => _PlacesNotifier(
              ref.watch(placeRepositoryProvider),
              journeyId,
            ));

class _PlacesNotifier extends StateNotifier<List<Place>> {
  _PlacesNotifier(this._repo, this.journeyId) : super(const []);

  final PlaceRepository _repo;
  final String journeyId;

  Future<void> refresh() async {
    state = _repo.getByJourney(journeyId);
  }

  Future<void> add({
    required String name,
    required double lat,
    required double lng,
    String category = 'general',
    int estimatedVisitMinutes = 60,
    bool completed = false,
    required String Function() genId,
  }) async {
    final p = Place(
      id: genId(),
      journeyId: journeyId,
      name: name,
      latitude: lat,
      longitude: lng,
      category: category,
      estimatedVisitMinutes: estimatedVisitMinutes,
      completed: completed,
    );
    await _repo.add(p);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}

class PlacesListView extends ConsumerWidget {
  const PlacesListView({super.key, required this.journeyId});

  final String journeyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(placesProvider(journeyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () async {
                // Minimal add UX for now
                final genId = ref.read(_uuidProvider).v4;
                final messenger = ScaffoldMessenger.of(context);
                await ref
                    .read(placesProvider(journeyId).notifier)
                    .add(name: 'Sample place', lat: 0, lng: 0, genId: genId);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Place added')),
                );
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Place (sample)'),
            ),
            const Spacer(),
          ],
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No places yet'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = items[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(
                    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)} • ${p.category} • ~${p.estimatedVisitMinutes}m'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref.read(placesProvider(journeyId).notifier).delete(p.id);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
