import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/booking.dart';
import 'package:matka/repositories/booking_repository.dart';
import 'package:matka/services/notifications_service.dart';
import 'package:uuid/uuid.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final service = NotificationsService();
  // Fire and forget initialize (can be awaited in UI as needed)
  service.initialize();
  return service;
});

class BookingListNotifier extends StateNotifier<List<Booking>> {
  BookingListNotifier(this._repo, this._notifications, this.journeyId)
      : super(const []);

  final BookingRepository _repo;
  final NotificationsService _notifications;
  final String journeyId;

  Future<void> refresh() async {
    state = _repo.getByJourney(journeyId);
  }

  Future<void> add({
    required BookingType type,
    required String provider,
    required DateTime start,
    required DateTime end,
    String? details,
    String? ticketImagePath,
    required String Function() genId,
  }) async {
    final booking = Booking(
      id: genId(),
      journeyId: journeyId,
      type: type,
      provider: provider,
      startDate: start,
      endDate: end,
      details: details ?? '',
      ticketImagePath: ticketImagePath,
    );

    await _repo.add(booking);
    await refresh();

    // Schedule reminders: 24h and 3h before start
    final id24 = booking.id.hashCode ^ 24;
    final id3 = booking.id.hashCode ^ 3;
    await _notifications.scheduleBookingReminder(
      id: id24,
      title: 'Upcoming ${booking.type.name} booking',
      body: '${booking.provider} in 24 hours',
      when: booking.startDate.subtract(const Duration(hours: 24)),
    );
    await _notifications.scheduleBookingReminder(
      id: id3,
      title: 'Upcoming ${booking.type.name} booking',
      body: '${booking.provider} in 3 hours',
      when: booking.startDate.subtract(const Duration(hours: 3)),
    );
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await _notifications.cancelBookingReminder(id.hashCode ^ 24);
    await _notifications.cancelBookingReminder(id.hashCode ^ 3);
    await refresh();
  }
}

final bookingListProvider = StateNotifierProvider.family<
    BookingListNotifier, List<Booking>, String>((ref, journeyId) {
  final repo = ref.watch(bookingRepositoryProvider);
  final notifications = ref.watch(notificationsServiceProvider);
  return BookingListNotifier(repo, notifications, journeyId);
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());
