import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearby_connect/models/user_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';

final currentFirebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(currentFirebaseUserProvider);

  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      final firestore = ref.watch(firestoreServiceProvider);
      return firestore.userStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (error, stack) => const Stream.empty(),
  );
});
