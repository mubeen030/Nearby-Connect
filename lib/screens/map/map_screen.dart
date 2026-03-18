import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart'; // Replaces google_maps_flutter
import 'package:latlong2/latlong.dart'; // Required for coordinates in flutter_map

import 'package:nearby_connect/models/user_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Changed from Completer<GoogleMapController> to MapController
  final MapController _mapController = MapController();

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
              
              // flutter_map uses a List of Markers instead of a Set
              final List<Marker> markers = [];

              // 1. Add Current User Marker (Blue)
              markers.add(
                Marker(
                  point: LatLng(currentUser.latitude, currentUser.longitude),
                  width: 80, // Width for the custom widget
                  height: 80,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                        child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ],
                  ),
                ),
              );

              // 2. Add Nearby Users Markers (Red)
              for (var user in users) {
                markers.add(
                  Marker(
                    point: LatLng(user.latitude, user.longitude),
                    width: 80,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
                          child: Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                      ],
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  // --- THE MAP ---
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(currentUser.latitude, currentUser.longitude),
                      initialZoom: 13.0,
                    ),
                    children: [
                      // Free Google Maps Tile Server (Hybrid: Satellite + Streets)
                      TileLayer(
                        urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                        userAgentPackageName: 'com.example.nearby_connect', // Best practice to set this
                      ),
                      // Layer to display the users
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),

                  // --- MY LOCATION BUTTON ---
                  // flutter_map doesn't have myLocationButtonEnabled built-in, so we add a FAB
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _mapController.move(
                          LatLng(currentUser.latitude, currentUser.longitude), 
                          15.0 // Zoom level when re-centering
                        );
                      },
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ),
                ],
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