import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connect/services/firestore_service.dart';
import 'package:nearby_connect/services/location_service.dart';
import 'package:nearby_connect/services/storage_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
