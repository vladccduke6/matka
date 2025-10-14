import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/repositories/packing_repository.dart';

final packingRepositoryProvider = Provider<PackingRepository>((ref) {
  return PackingRepository();
});
