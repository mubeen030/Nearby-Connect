import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connect/models/message_model.dart';
import 'package:nearby_connect/providers/service_providers.dart';
import 'package:nearby_connect/providers/user_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _isEmojiVisible = false;
  bool _isSending = false;

  void _toggleEmoji() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentFirebaseUserProvider).value;
    if (user == null) return;

    final firestore = ref.read(firestoreServiceProvider);
    final message = Message(
      messageId: '',
      senderId: user.uid,
      type: MessageType.text,
      text: text,
      mediaUrl: '',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    _controller.clear();
    try {
      await firestore.sendMessage(widget.chatId, message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  Future<void> _sendMedia({required MessageType type}) async {
    final user = ref.read(currentFirebaseUserProvider).value;
    if (user == null) return;

    final picker = ImagePicker();
    XFile? picked;

    if (type == MessageType.image) {
      picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    } else if (type == MessageType.video) {
      picked = await picker.pickVideo(source: ImageSource.gallery);
    }

    if (picked == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final file = File(picked.path);
      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadMessageMedia(
        chatId: widget.chatId,
        userId: user.uid,
        fileName: picked.name,
        file: file,
      );

      final message = Message(
        messageId: '',
        senderId: user.uid,
        type: type,
        text: '',
        mediaUrl: url,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        fileName: picked.name,
      );
      await ref.read(firestoreServiceProvider).sendMessage(widget.chatId, message);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.name.toUpperCase()} sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send ${type.name}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendFile() async {
    final user = ref.read(currentFirebaseUserProvider).value;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    if (fileBytes == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final temp = File('${Directory.systemTemp.path}/$fileName');
      await temp.writeAsBytes(fileBytes);

      final storage = ref.read(storageServiceProvider);
      final url = await storage.uploadMessageMedia(
        chatId: widget.chatId,
        userId: user.uid,
        fileName: fileName,
        file: temp,
      );

      final message = Message(
        messageId: '',
        senderId: user.uid,
        type: MessageType.file,
        text: fileName,
        mediaUrl: url,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        fileName: fileName,
      );

      await ref.read(firestoreServiceProvider).sendMessage(widget.chatId, message);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Message message, bool isMine) {
    final theme = Theme.of(context);
    final bgColor = isMine ? theme.colorScheme.primary : theme.cardColor;
    final textColor = isMine ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color;

    Widget content;
    if (message.type == MessageType.text) {
      content = Text(message.text, style: TextStyle(color: textColor));
    } else if (message.type == MessageType.image) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(message.mediaUrl, width: 200, fit: BoxFit.cover),
      );
    } else if (message.type == MessageType.video) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.videocam),
          Text('Video', style: TextStyle(color: textColor)),
        ],
      );
    } else if (message.type == MessageType.audio) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.audiotrack),
          const SizedBox(width: 6),
          Text('Voice message', style: TextStyle(color: textColor)),
        ],
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message.fileName ?? 'File',
              style: TextStyle(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = ref.read(firestoreServiceProvider);
    final currentUser = ref.watch(currentFirebaseUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: firestore.messagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = currentUser != null && message.senderId == currentUser.uid;
                    return _buildMessageBubble(message, isMine);
                  },
                );
              },
            ),
          ),
          if (_isSending) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onPressed: _toggleEmoji,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: _sendFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () => _sendMedia(type: MessageType.image),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendText,
                    ),
                  ],
                ),
                if (_isEmojiVisible)
                  SizedBox(
                    height: 300,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        _controller.text += emoji.emoji;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
