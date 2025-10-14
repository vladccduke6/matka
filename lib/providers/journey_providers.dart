import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/core/db/app_database.dart';
import 'package:matka/models/journey.dart';
import 'package:matka/repositories/journey_repository.dart';
import 'package:uuid/uuid.dart';

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return JourneyRepository(db);
});

class JourneyListNotifier extends StateNotifier<List<Journey>> {
  JourneyListNotifier(this._repo) : super(const []) {
    _init();
  }

  final JourneyRepository _repo;

  Future<void> _init() async {
    final items = await _repo.getAllJourneys();
    state = items;
  }

  Future<void> refresh() async {
    state = await _repo.getAllJourneys();
  }

  Future<void> add({
    required String title,
    required DateTime start,
    required DateTime end,
    required DateTime createdAt,
    required String Function() genId,
  }) async {
    final journey = Journey(
      id: genId(),
      title: title,
      startDate: start,
      endDate: end,
      createdAt: createdAt,
    );
    await _repo.addJourney(journey);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteJourney(id);
    await refresh();
  }

  Future<void> update(Journey j) async {
    await _repo.updateJourney(j);
    await refresh();
  }
}

final journeyListProvider =
    StateNotifierProvider<JourneyListNotifier, List<Journey>>((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  return JourneyListNotifier(repo);
});
