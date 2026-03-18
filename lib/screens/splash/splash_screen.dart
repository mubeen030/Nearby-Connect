import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';
import 'package:nearby_connect/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  StreamSubscription? _locationSub;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final router = GoRouter.of(context);
    final user = ref.read(currentFirebaseUserProvider).value;

    if (user != null) {
      await _startLocationTracking(user.uid);
      router.go(Routes.home);
    } else {
      router.go(Routes.login);
    }
  }

  Future<void> _startLocationTracking(String userId) async {
    final locationService = ref.read(locationServiceProvider);
    final firestore = ref.read(firestoreServiceProvider);

    final hasPermission = await locationService.requestPermissions();
    if (!hasPermission) return;

    final position = await locationService.getCurrentPosition();
    await firestore.updateUserLocation(userId, position.latitude, position.longitude);
    await firestore.updateOnlineStatus(userId, true);

    _locationSub = locationService.getPositionStream().listen((position) {
      firestore.updateUserLocation(userId, position.latitude, position.longitude);
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B2EFB), Color(0xFF2248F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0x80FFFFFF)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'NC',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nearby Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
