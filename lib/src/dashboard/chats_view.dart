import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'package:intl/intl.dart';
import 'conversation_screen.dart';

class ChatsView extends StatefulWidget {
  ChatsView({super.key, required this.chatType});

  final ChatRoomType chatType;

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  var messagesCollection = firestore
      .collection('messages')
      .where('participants', arrayContains: currentUserProfile);

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

          if (snapshot.hasData) {
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
                      DocumentReference? messageSnapshot =
                          messages?[index].get('last_message');
                      return FutureBuilder<DocumentSnapshot>(
                          future: messageSnapshot?.get(),
                          builder: (context, lastMessageSnapshot) {
                            if (lastMessageSnapshot.hasData) {
                              Map<String, dynamic>? lastMessageData =
                                  lastMessageSnapshot.data?.data()
                                      as Map<String, dynamic>?;
                              return FutureBuilder<DocumentSnapshot>(
                                  future: (lastMessageData?['senderID']
                                          as DocumentReference)
                                      .collection('account_type')
                                      .doc('patrone')
                                      .get(),
                                  builder: (context, senderSnapshot) {
                                    if (senderSnapshot.hasData) {
                                      Map<String, dynamic>? senderData =
                                          senderSnapshot.data?.data()
                                              as Map<String, dynamic>?;
                                      return ListTile(
                                        onTap: () => Navigator.push(context, 
                                        MaterialPageRoute(builder: (context) => ConversationScreen(chats: messages![index].reference))),
                                        leading: CircleAvatar(
                                          radius: 30,
                                          foregroundImage: NetworkImage(
                                              senderData!['profile_picture']),
                                        ),
                                        title: Text(
                                            '${senderData?['first_name'] ?? ''} ${senderData?['last_name'] ?? ''}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            '${lastMessageData?['senderID'] == currentUserProfile ? 'You: ' : ''}${lastMessageData?['content'] ?? 'test'}'),
                                        trailing: Text(DateFormat('HH:mm')
                                            .format(
                                                (lastMessageData?['time_sent']
                                                        as Timestamp)
                                                    .toDate())),
                                      );
                                    }
                                    return Center(
                                        child: CircularProgressIndicator());
                                  });
                            }
                            return Center(child: CircularProgressIndicator());
                          });
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
