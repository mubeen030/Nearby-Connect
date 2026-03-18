import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connect/models/chat_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';

final chatsProvider = StreamProvider<List<Chat>>((ref) {
  final authState = ref.watch(currentFirebaseUserProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      final firestore = ref.watch(firestoreServiceProvider);
      return firestore.chatsForUser(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (error, stack) => const Stream.empty(),
  );
});
