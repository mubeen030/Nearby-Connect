import 'package:cloud_firestore/cloud_firestore.dart';

/// A minimal model representing a user stored in Firestore.
class AppUser {
  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.onlineStatus,
    required this.lastSeen,
  });

  final String userId;
  final String name;
  final String email;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final bool onlineStatus;
  final DateTime lastSeen;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      userId: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      onlineStatus: data['onlineStatus'] as bool? ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'onlineStatus': onlineStatus,
      'lastSeen': Timestamp.fromDate(lastSeen),
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? photoUrl,
    double? latitude,
    double? longitude,
    bool? onlineStatus,
    DateTime? lastSeen,
  }) {
    return AppUser(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
