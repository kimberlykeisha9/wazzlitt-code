import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'conversation_screen.dart';

class ChatsView extends StatefulWidget {
  ChatsView({super.key, required this.chatType});

  final ChatRoomType chatType;

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  var messagesCollection =
  firestore.collection('messages').where('participants', arrayContains:
  currentUserProfile);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: messagesCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          DocumentReference? senderId;
          String? content;
          Timestamp? timestamp;

          List<DocumentSnapshot>? messages = snapshot.data?.docs;

          log(messages.toString());
          log(messages?.length.toString() ?? 'null');
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages?.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentReference? messageSnapshot = messages?[index].get
                      ('last_message');
                    return FutureBuilder<DocumentSnapshot>(
                      future: messageSnapshot?.get(),
                      builder: (context, snapshot) {
                        return ListTile(
                          title: Text(snapshot.data?.get('content') ?? 'test'),
                          subtitle: Text('Sender: ${(snapshot.data?.get
                            ('senderID') as DocumentReference).id}'),
                          trailing: Text((snapshot.data?.get('time_sent') as
                          Timestamp)
                              .toDate().toString
                            ()),
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
