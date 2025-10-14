import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/repositories/place_repository.dart';

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository();
});
