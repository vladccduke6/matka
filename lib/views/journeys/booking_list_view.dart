import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matka/models/booking.dart';
import 'package:matka/providers/booking_providers.dart';

class BookingListView extends ConsumerWidget {
  const BookingListView({super.key, required this.journeyId});

  final String journeyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingListProvider(journeyId));

    if (bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No bookings yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final Booking b = bookings[index];
        final range = '${b.startDate.toLocal().toString().split(' ').first} — ${b.endDate.toLocal().toString().split(' ').first}';
        return ListTile(
          leading: Icon(_iconFor(b.type)),
          title: Text(b.provider),
          subtitle: Text('${b.type.name.toUpperCase()} • $range'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(bookingListProvider(journeyId).notifier).delete(b.id);
              messenger.showSnackBar(
                const SnackBar(content: Text('Booking deleted')),
              );
            },
          ),
        );
      },
    );
  }

  IconData _iconFor(BookingType type) {
    switch (type) {
      case BookingType.train:
        return Icons.train;
      case BookingType.flight:
        return Icons.flight_takeoff;
      case BookingType.hotel:
        return Icons.hotel;
    }
  }
}
