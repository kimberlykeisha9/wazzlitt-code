import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app.dart';

class ConversationScreen extends StatefulWidget {
  final Chat chat;
  final ChatRoomType chatType;

  const ConversationScreen({super.key, required this.chat, required this.chatType});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = TextEditingController();
  final Chat test = Chat(
      senderName: 'Business',
      chatType: ChatRoomType.individual,
      senderImage: 'assets/images/david_johnson_avatar.jpg',
      messages: [
        Message(
          senderName: 'You',
          content: 'How is everything going',
          time: 'Yesterday',
        ),
        Message(
          senderName: 'David Johnson',
          content: 'Everything is cool over here',
          time: 'Yesterday',
        ),
        Message(
          senderName: 'Moses Mbuva',
          content: 'Want to go grab a drink?',
          time: 'Yesterday',
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.senderName), actions: [
        IconButton(icon: const Icon(Icons.account_circle), onPressed: () {})
      ]),
      body: SafeArea(
        child: test.chatType == ChatRoomType.individual
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: test.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final isUser =
                      widget.chat.messages[index].senderName == 'You';
                  final message = widget.chat.messages[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: const Icon(Icons.park),
                    tileColor: isUser
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.25)
                        : null,
                    title: Text(
                      message.senderName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    subtitle: Text(message.content),
                    trailing: Text(message.time,
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              )
            : Column(
                children: [
                  Container(
                    height: 150,
                    width: width(context),
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to ${widget.chat.senderName}\'s Chatroom',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 20),
                        const Text(
                          'This is where people get to talk and inform each other '
                          'about what is going on at your business place. All messages '
                          'expire after 24 hours.',
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                      child: SizedBox(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.chat.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final isUser =
                            widget.chat.messages[index].senderName == 'You';
                        final message = widget.chat.messages[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: const Icon(Icons.park),
                          tileColor: isUser
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.25)
                              : null,
                          title: Text(
                            message.senderName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          subtitle: Text(message.content),
                          trailing: Text(message.time,
                              style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  )),
                ],
              ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 10,
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Send a message...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  final content = messageController.text;
                  final time = DateFormat.jm().format(DateTime.now());
                  widget.chat.messages.add(
                      Message(content: content, time: time, senderName: 'You'));
                  messageController.clear();
                });
              },
              icon: Icon(Icons.send,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
