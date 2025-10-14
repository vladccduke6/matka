import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/repositories/buddy_repository.dart';
import 'package:matka/models/buddy.dart';

final buddyRepositoryProvider = Provider<BuddyRepository>((ref) {
  return BuddyRepository();
});

final buddiesForJourneyProvider = Provider.family<List<Buddy>, String>((ref, journeyId) {
  final repo = ref.watch(buddyRepositoryProvider);
  return repo.forJourney(journeyId);
});
