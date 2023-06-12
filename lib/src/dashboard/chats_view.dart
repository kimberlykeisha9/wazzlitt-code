import 'package:flutter/material.dart';
import '../app.dart';
import 'conversation_screen.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({super.key, required this.chatType});

  final ChatRoomType chatType;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatData.length,
      itemBuilder: (BuildContext context, int index) {
        final chat = chatData[index];
        return ListTile(
          leading: const Icon(Icons.park),
          title: Text(
            chat.senderName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          subtitle: Text(
            chat.messages.isNotEmpty
                ? chat.messages.last.senderName == 'You'
                    ? 'You: ${chat.messages.last.content}'
                    : chat.messages.last.content
                : '',
          ),
          trailing: Text(
              chat.messages.isNotEmpty ? chat.messages.last.time : '',
              style: const TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                    chat: chat, chatType: ChatRoomType.individual),
              ),
            );
          },
        );
      },
    );
  }
}
