import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connect/providers/auth_provider.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';
import 'package:nearby_connect/router/app_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  Future<void> _pickProfilePhoto(String userId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() => _isLoading = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadUserPhoto(userId, File(picked.path));

      final currentUser = ref.read(currentAppUserProvider).value;
      if (currentUser == null) return;

      final firestore = ref.read(firestoreServiceProvider);
      await firestore.createOrUpdateUser(
        currentUser.copyWith(photoUrl: url),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile data.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child: user.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickProfilePhoto(user.userId),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.edit, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Name', style: Theme.of(context).textTheme.labelLarge),
                Text(user.name, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text('Email', style: Theme.of(context).textTheme.labelLarge),
                Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text('Status', style: Theme.of(context).textTheme.labelLarge),
                Text(
                  user.onlineStatus ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text('Last seen', style: Theme.of(context).textTheme.labelLarge),
                Text(
                  user.lastSeen.toLocal().toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_isLoading) const LinearProgressIndicator(),
                SwitchListTile(
                  value: user.onlineStatus,
                  title: const Text('Appear online'),
                  onChanged: (value) async {
                    final firestore = ref.read(firestoreServiceProvider);
                    await firestore.updateOnlineStatus(user.userId, value);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}