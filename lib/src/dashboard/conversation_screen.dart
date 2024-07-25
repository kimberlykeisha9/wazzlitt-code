import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';

import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';

class ConversationScreen extends StatefulWidget {
  final DocumentReference chats;

  ConversationScreen({Key? key, required this.chats}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.chats.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        }

        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: Text('No data found')));
        }

        final Map<String, dynamic> chatsInfo =
            snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Conversation'),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  // Implement the action for the account circle button
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (chatsInfo.containsKey('identifier'))
                _buildChatHeader(chatsInfo),
              Expanded(
                child: _ChatMessagesStream(
                    chatsCollection: widget.chats.collection('chats')),
              ),
            ],
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    minLines: 1,
                    maxLines: 10,
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Send a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    _sendMessage(widget.chats.collection('chats'),
                            _messageController.text)
                        .then((_) => _messageController.clear());
                  },
                  icon: Icon(Icons.send,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatHeader(Map<String, dynamic> chatsInfo) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatsInfo['owner'].get(),
      builder: (context, ownerSnapshot) {
        if (ownerSnapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (ownerSnapshot.hasError) {
          return Text('Error: ${ownerSnapshot.error}');
        }

        final ownerData = ownerSnapshot.data!.data() as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(ownerData['image'] ??
                  'https://i.pinimg.com/564x/60/9a/37/609a375345b463141ec4c875ee2f1104.jpg'),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chatsInfo['welcome_message'] ?? 'Welcome to the chat!'),
              const SizedBox(height: 5),
              const Text(
                  'All chats older than 24 hours are cleared automatically'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage(
      CollectionReference chatsCollection, String message) async {
    if (message.isEmpty) return;

    await chatsCollection.add({
      'content': message,
      'senderID': currentUserProfile,
      'time_sent': Timestamp.now(),
    });
  }
}

class _ChatMessagesStream extends StatelessWidget {
  final CollectionReference chatsCollection;

  _ChatMessagesStream({required this.chatsCollection});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatsCollection.orderBy('time_sent').snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatSnapshot.hasError) {
          return Center(child: Text('Error: ${chatSnapshot.error}'));
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        final chats = chatSnapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chatDoc = chats[index];
            return _ChatMessageTile(chatDoc: chatDoc);
          },
        );
      },
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> chatDoc;

  _ChatMessageTile({required this.chatDoc});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: chatDoc.reference.get(),
      builder: (context, messageSnapshot) {
        if (messageSnapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (messageSnapshot.hasError) {
          return Text('Error: ${messageSnapshot.error}');
        }

        final message = messageSnapshot.data!.data() as Map<String, dynamic>;
        final isUser = message['senderID'] == currentUserProfile;

        return FutureBuilder<DocumentSnapshot>(
          future: message['senderID']
              .collection('account_type')
              .doc('patrone')
              .get(),
          builder: (context, senderSnapshot) {
            if (senderSnapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            if (senderSnapshot.hasError) {
              return Text('Error: ${senderSnapshot.error}');
            }

            if (!senderSnapshot.hasData) {
              return const SizedBox();
            }

            final senderData =
                senderSnapshot.data!.data() as Map<String, dynamic>;

            return ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(
                              '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}'),
                        ),
                        body: FutureBuilder<Patrone>(
                          future: Patrone()
                              .getPatroneInformation(message['senderID']),
                          builder: (context, profileSnapshot) {
                            if (profileSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (profileSnapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Error: ${profileSnapshot.error}'));
                            }

                            return ProfileScreen(
                                userProfile: profileSnapshot.data!);
                          },
                        ),
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(senderData['profile_picture'] ??
                      'https://example.com/default_profile_picture.png'),
                ),
              ),
              tileColor: isUser
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.25)
                  : null,
              title: Text(
                  '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(message['content']),
              trailing: Text(DateFormat('HH:mm')
                  .format((message['time_sent'] as Timestamp).toDate())),
            );
          },
        );
      },
    );
  }
}
