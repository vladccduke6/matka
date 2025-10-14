import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:matka/models/journey.dart';
import 'package:matka/models/booking.dart';
import 'package:matka/models/place.dart';
import 'package:matka/models/packing_item.dart';
import 'package:matka/models/buddy.dart';
import 'package:matka/repositories/booking_repository.dart';
import 'package:matka/repositories/place_repository.dart';
import 'package:matka/repositories/packing_repository.dart';
import 'package:matka/repositories/buddy_repository.dart';
import 'package:matka/repositories/journey_repository.dart';

class ExportResult {
  final File jsonFile;
  final List<String> imagePaths; // placeholder for future image exports
  ExportResult(this.jsonFile, this.imagePaths);
}

class ExportImportService {
  ExportImportService({
    required JourneyRepository journeys,
    required BookingRepository bookings,
    required PlaceRepository places,
    required PackingRepository packing,
    required BuddyRepository buddies,
  })  : _journeys = journeys,
        _bookings = bookings,
        _places = places,
        _packing = packing,
        _buddies = buddies;

  final JourneyRepository _journeys;
  final BookingRepository _bookings;
  final PlaceRepository _places;
  final PackingRepository _packing;
  final BuddyRepository _buddies;

  Future<ExportResult> exportJourney(String journeyId) async {
    // Fetch entities
    final allJourneys = await _journeys.getAllJourneys();
    final journey = allJourneys.firstWhere((j) => j.id == journeyId);
    final bookings = _bookings.getByJourney(journeyId);
    final places = _places.getByJourney(journeyId);
    final packing = _packing.getByJourney(journeyId);
    final buddies = _buddies.forJourney(journeyId);

    final jsonMap = {
      'journey': journey.toMap(),
      'bookings': bookings.map((e) => e.toMap()).toList(),
      'places': places.map((e) => e.toMap()).toList(),
      'packing': packing.map((e) => e.toMap()).toList(),
      'buddies': buddies.map((e) => e.toMap()).toList(),
      'version': 1,
    };

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'matka_export_${journey.title}_${journey.id}.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonMap));
    return ExportResult(file, const <String>[]);
  }

  Future<Journey> importJourney(File jsonFile) async {
    final content = await jsonFile.readAsString();
    final map = jsonDecode(content) as Map<String, dynamic>;

    // Rehydrate model objects
    final journey = Journey.fromMap(map['journey'] as Map<String, dynamic>);
    final bookings = (map['bookings'] as List<dynamic>).map((e) => Booking.fromMap(e as Map<String, dynamic>)).toList();
    final places = (map['places'] as List<dynamic>).map((e) => Place.fromMap(e as Map<String, dynamic>)).toList();
    final packing = (map['packing'] as List<dynamic>).map((e) => PackingItem.fromMap(e as Map<String, dynamic>)).toList();
    final buddies = (map['buddies'] as List<dynamic>).map((e) => Buddy.fromMap(e as Map<String, dynamic>)).toList();

    // Persist journey and related items
    await _journeys.addJourney(journey);
    for (final b in bookings) {
      await _bookings.add(b);
    }
    for (final p in places) {
      await _places.add(p);
    }
    for (final i in packing) {
      await _packing.add(i);
    }
    for (final buddy in buddies) {
      await _buddies.addBuddy(buddy);
      await _buddies.attachToJourney(journey.id, buddy.id);
    }

    return journey;
  }
}
