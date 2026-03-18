import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_connect/models/user_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    final firestore = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: currentUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Please sign in to view the map.'));
          }
          return StreamBuilder<List<AppUser>>(
            stream: firestore.nearbyUsersStream(currentUser.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final users = snapshot.data ?? [];
              final markers = <Marker>{
                Marker(
                  markerId: MarkerId('me'),
                  position: LatLng(currentUser.latitude, currentUser.longitude),
                  infoWindow: InfoWindow(title: 'You', snippet: currentUser.name),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                ),
              };

              markers.addAll(users.map((user) {
                return Marker(
                  markerId: MarkerId(user.userId),
                  position: LatLng(user.latitude, user.longitude),
                  infoWindow: InfoWindow(title: user.name, snippet: user.email),
                );
              }));

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentUser.latitude, currentUser.longitude),
                  zoom: 13,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
