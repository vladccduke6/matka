import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/providers/journey_providers.dart';
import 'package:matka/providers/booking_providers.dart';
import 'package:matka/providers/place_providers.dart';
import 'package:matka/providers/packing_providers.dart';
import 'package:matka/providers/buddy_providers.dart';
import 'package:matka/services/export_import_service.dart';

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService(
    journeys: ref.watch(journeyRepositoryProvider),
    bookings: ref.watch(bookingRepositoryProvider),
    places: ref.watch(placeRepositoryProvider),
    packing: ref.watch(packingRepositoryProvider),
    buddies: ref.watch(buddyRepositoryProvider),
  );
});
