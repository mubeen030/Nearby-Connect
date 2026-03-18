import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, audio, file }

enum MessageStatus { sent, delivered, seen }

class Message {
  Message({
    required this.messageId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.mediaUrl,
    required this.timestamp,
    required this.status,
    this.fileName,
  });

  final String messageId;
  final String senderId;
  final MessageType type;
  final String text;
  final String mediaUrl;
  final DateTime timestamp;
  final MessageStatus status;
  final String? fileName;

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Message(
      messageId: doc.id,
      senderId: data['senderId'] as String? ?? '',
      type: _messageTypeFromString(data['type'] as String? ?? 'text'),
      text: data['text'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _messageStatusFromString(data['status'] as String? ?? 'sent'),
      fileName: data['fileName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'type': _messageTypeToString(type),
      'text': text,
      'mediaUrl': mediaUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': _messageStatusToString(status),
      'fileName': fileName,
    };
  }

  Message copyWith({
    String? messageId,
    String? senderId,
    MessageType? type,
    String? text,
    String? mediaUrl,
    DateTime? timestamp,
    MessageStatus? status,
    String? fileName,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
    );
  }

  static const _typeFromString = <String, MessageType>{
    'text': MessageType.text,
    'image': MessageType.image,
    'video': MessageType.video,
    'audio': MessageType.audio,
    'file': MessageType.file,
  };

  static const _typeToString = <MessageType, String>{
    MessageType.text: 'text',
    MessageType.image: 'image',
    MessageType.video: 'video',
    MessageType.audio: 'audio',
    MessageType.file: 'file',
  };

  static const _statusFromString = <String, MessageStatus>{
    'sent': MessageStatus.sent,
    'delivered': MessageStatus.delivered,
    'seen': MessageStatus.seen,
  };

  static const _statusToString = <MessageStatus, String>{
    MessageStatus.sent: 'sent',
    MessageStatus.delivered: 'delivered',
    MessageStatus.seen: 'seen',
  };

  static MessageType _messageTypeFromString(String value) =>
      _typeFromString[value] ?? MessageType.text;

  static String _messageTypeToString(MessageType type) =>
      _typeToString[type] ?? 'text';

  static MessageStatus _messageStatusFromString(String value) =>
      _statusFromString[value] ?? MessageStatus.sent;

  static String _messageStatusToString(MessageStatus status) =>
      _statusToString[status] ?? 'sent';
}

