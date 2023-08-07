import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../user_data/user_data.dart';
import '../app.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({super.key, required this.chats});
  DocumentReference chats;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.chats.collection('chats').orderBy('time_sent').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Object?>> chats = snapshot.data!.docs;
            print(chats.length);
            return Scaffold(
              appBar: AppBar(title: Text('Conversation'), actions: [
                IconButton(
                    icon: const Icon(Icons.account_circle), onPressed: () {})
              ]),
              body: SafeArea(
                  child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: chats.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder<DocumentSnapshot>(
                      future: chats[index].reference.get(),
                      builder: (context, messageSnapshot) {
                        Map<String, dynamic> message = messageSnapshot.data!
                            .data() as Map<String, dynamic>;
                        print('This is the message: $message');
                        bool isUser = message['senderID'] == currentUserProfile;
                        return FutureBuilder<DocumentSnapshot>(
                            future: message['senderID'].collection('account_type').doc('patrone').get(),
                            builder: (context, senderSnapshot) {
                              if (senderSnapshot.hasData) {
                                Map<String, dynamic> senderData =
                                    senderSnapshot.data?.data()
                                        as Map<String, dynamic>;
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    foregroundImage: NetworkImage(
                                        senderData['profile_picture']),
                                  ),
                                  tileColor: isUser
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.25)
                                      : null,
                                  title: Text(
                                      '${senderData?['first_name'] ?? ''} ${senderData?['last_name'] ?? ''}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(message['content']),
                                  trailing: Text(DateFormat('HH:mm').format(
                                      (message?['time_sent'] as Timestamp)
                                          .toDate())),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            });
                      });
                },
              )),
              bottomSheet: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                        sendMessage(widget.chats.collection('chats'), messageController.text).then((value) => messageController.clear());
                      },
                      icon: Icon(Icons.send,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
