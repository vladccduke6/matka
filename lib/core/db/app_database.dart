import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('JourneyRow')
class Journeys extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Journeys])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // DAO-like convenience methods for journeys
  Future<List<JourneyRow>> getAllJourneys() => (select(journeys)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).
      get();
  Future<void> insertJourney(JourneysCompanion entity) => into(journeys).insert(entity);
  Future<int> deleteJourneyById(String id) => (delete(journeys)..where((tbl) => tbl.id.equals(id))).go();
  Future<bool> updateJourneyRow(JourneysCompanion entity) => update(journeys).replace(entity);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'matka.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
