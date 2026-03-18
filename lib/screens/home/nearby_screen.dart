import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nearby_connect/models/user_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';
import 'package:nearby_connect/utils/geo.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  double _radiusKm = 3;

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentAppUserProvider);
    final firestore = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby People'),
        centerTitle: true,
      ),
      body: currentUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('Please sign in to see nearby people.'));
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
              final filtered = users.where((u) {
                final dist = distanceBetweenKm(
                  currentUser.latitude,
                  currentUser.longitude,
                  u.latitude,
                  u.longitude,
                );
                return dist <= _radiusKm;
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text('Radius:'),
                        const SizedBox(width: 12),
                        DropdownButton<double>(
                          value: _radiusKm,
                          items: const [1, 3, 5].map((value) {
                            return DropdownMenuItem<double>(
                              value: value.toDouble(),
                              child: Text('$value km'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _radiusKm = value;
                              });
                            }
                          },
                        ),
                        const Spacer(),
                        // ✅ Fixed refresh button
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            ref.invalidate(locationUpdateProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No people found in this radius.'),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final user = filtered[index];
                              final dist = distanceBetweenKm(
                                currentUser.latitude,
                                currentUser.longitude,
                                user.latitude,
                                user.longitude,
                              );
                              return _NearbyUserCard(
                                user: user,
                                distanceKm: dist,
                                onTap: () async {
                                  final router = GoRouter.of(context);
                                  final chatId = await firestore.ensureChatExists(
                                    [currentUser.userId, user.userId],
                                  );
                                  router.go('/home/chat/$chatId');
                                },
                              );
                            },
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

class _NearbyUserCard extends StatelessWidget {
  const _NearbyUserCard({
    required this.user,
    required this.distanceKm,
    required this.onTap,
  });

  final AppUser user;
  final double distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(user.name.isNotEmpty ? user.name : user.email),
        subtitle: Text('${distanceKm.toStringAsFixed(1)} km away'),
        trailing: user.onlineStatus
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}