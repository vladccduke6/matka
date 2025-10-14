import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matka/models/place.dart';
import 'package:matka/views/places/places_list_view.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key, required this.journeyId, this.apiKey});

  final String journeyId;
  final String? apiKey; // dummy for now; if null/empty show placeholder

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider(journeyId));

    if ((apiKey ?? '').isEmpty) {
      return const Center(
        child: Text('Google Maps API key missing. Map disabled.'),
      );
    }

    final markers = places
        .map(
          (Place p) => Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.latitude, p.longitude),
            infoWindow: InfoWindow(title: p.name, snippet: p.category),
          ),
        )
        .toSet();

    final initial = places.isNotEmpty
        ? CameraPosition(
            target: LatLng(places.first.latitude, places.first.longitude),
            zoom: 12,
          )
        : const CameraPosition(target: LatLng(0, 0), zoom: 1);

    return GoogleMap(
      initialCameraPosition: initial,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: markers,
      zoomControlsEnabled: true,
    );
  }
}
