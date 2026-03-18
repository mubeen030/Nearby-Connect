import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nearby_connect/providers/chat_provider.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet. Start a conversation by tapping a user from Nearby.'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text(chat.lastMessage.isNotEmpty ? chat.lastMessage : 'New chat'),
                subtitle: Text('Participants: ${chat.participants.length}'),
                trailing: Text(
                  chat.lastUpdated.toLocal().toString().split('.').first,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  context.go('/home/chat/${chat.chatId}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
