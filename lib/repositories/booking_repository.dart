import 'package:matka/models/booking.dart';

class BookingRepository {
  final List<Booking> _items = [];

  List<Booking> getByJourney(String journeyId) {
    final list = _items.where((b) => b.journeyId == journeyId).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return List.unmodifiable(list);
  }

  Future<void> add(Booking booking) async {
    _items.add(booking);
  }

  Future<void> delete(String id) async {
    _items.removeWhere((b) => b.id == id);
  }

  Future<void> update(Booking updated) async {
    final idx = _items.indexWhere((b) => b.id == updated.id);
    if (idx != -1) _items[idx] = updated;
  }
}
