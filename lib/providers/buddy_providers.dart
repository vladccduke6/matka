import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/repositories/buddy_repository.dart';

final buddyRepositoryProvider = Provider<BuddyRepository>((ref) {
  return BuddyRepository();
});
