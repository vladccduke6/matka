import 'package:drift/drift.dart' as drift;
import 'package:matka/core/db/app_database.dart';
import 'package:matka/models/journey.dart' as domain;

class JourneyRepository {
  JourneyRepository(this._db);

  final AppDatabase _db;

  static JourneysCompanion _toCompanion(domain.Journey j) {
    return JourneysCompanion(
      id: drift.Value(j.id),
      title: drift.Value(j.title),
      startDate: drift.Value(j.startDate),
      endDate: drift.Value(j.endDate),
      createdAt: drift.Value(j.createdAt),
    );
  }

  static domain.Journey _toDomain(JourneyRow row) {
    return domain.Journey(
      id: row.id,
      title: row.title,
      startDate: row.startDate,
      endDate: row.endDate,
      createdAt: row.createdAt,
    );
  }

  Future<List<domain.Journey>> getAllJourneys() async {
    try {
      final rows = await _db.getAllJourneys();
      return rows.map(_toDomain).toList(growable: false);
    } catch (e) {
      // In a real app, log this to a logger/Crashlytics
      rethrow;
    }
  }

  Future<void> addJourney(domain.Journey journey) async {
    try {
      await _db.insertJourney(_toCompanion(journey));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJourney(String id) async {
    try {
      await _db.deleteJourneyById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateJourney(domain.Journey updated) async {
    try {
      await _db.updateJourneyRow(_toCompanion(updated));
    } catch (e) {
      rethrow;
    }
  }
}
