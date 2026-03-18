import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat/conversation between participants.
class Chat {
  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdated,
  });

  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdated;

  factory Chat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Chat(
      chatId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
