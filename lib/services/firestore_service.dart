import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearby_connect/models/chat_model.dart';
import 'package:nearby_connect/models/message_model.dart';
import 'package:nearby_connect/models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get usersRef => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get chatsRef => _firestore.collection('chats');

  Future<void> createOrUpdateUser(AppUser user) {
    return usersRef.doc(user.userId).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateUserLocation(String userId, double lat, double lon) {
    return usersRef.doc(userId).set(
      {
        'latitude': lat,
        'longitude': lon,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateOnlineStatus(String userId, bool online) {
    return usersRef.doc(userId).set(
      {
        'onlineStatus': online,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<AppUser> userStream(String userId) {
    return usersRef.doc(userId).snapshots().map((doc) => AppUser.fromFirestore(doc));
  }

  Stream<List<AppUser>> nearbyUsersStream(String currentUserId) {
    return usersRef.snapshots().map((snapshot) {
      // If current user doesn't exist yet, just return others.
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map(AppUser.fromFirestore)
          .toList();
    });
  }

  Future<String> ensureChatExists(List<String> participants) async {
    // Look for existing chat with same participants (order independent).
    final query = await chatsRef
        .where('participants', arrayContainsAny: participants)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final existing = List<String>.from(data['participants'] ?? []);
      if (existing.toSet().containsAll(participants) && participants.toSet().containsAll(existing)) {
        return doc.id;
      }
    }

    final newChat = await chatsRef.add({
      'participants': participants,
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    return newChat.id;
  }

  Stream<List<Chat>> chatsForUser(String userId) {
    return chatsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Chat.fromFirestore).toList());
  }

  Stream<List<Message>> messagesStream(String chatId) {
    return chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Message.fromFirestore).toList());
  }

  Future<void> sendMessage(String chatId, Message message) async {
    try {
      final messageRef = chatsRef.doc(chatId).collection('messages').doc();
      await messageRef.set(message.copyWith(messageId: messageRef.id).toFirestore());

      await chatsRef.doc(chatId).set(
        {
          'lastMessage': message.text.isNotEmpty ? message.text : (message.type.name),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Log error for debugging
      print('Firestore sendMessage error: $e');
      rethrow;
    }
  }
}
