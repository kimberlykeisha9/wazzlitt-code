import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'package:intl/intl.dart';
import 'conversation_screen.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key, required this.chatType});

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
    return Container(
      height: height(context),
      width: width(context),
      decoration: BoxDecoration(
        image: moon,
      ),
      child: SafeArea(
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
              List<DocumentSnapshot>? messages = snapshot.data?.docs;

              log(messages.toString());
              log(messages?.length.toString() ?? 'null');
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages?.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> messageData =
                            messages?[index].data() as Map<String, dynamic>;
                        (messageData['participants'] as List<dynamic>)
                            .remove(currentUserProfile);
                        DocumentReference receiver =
                            messageData['participants'][0];
                        DocumentReference? messageSnapshot =
                            messageData['last_message'];
                        return FutureBuilder<DocumentSnapshot>(
                            future: messageSnapshot?.get(),
                            builder: (context, lastMessageSnapshot) {
                              if (lastMessageSnapshot.hasData) {
                                Map<String, dynamic>? lastMessageData =
                                    lastMessageSnapshot.data?.data()
                                        as Map<String, dynamic>?;
                                return FutureBuilder<DocumentSnapshot>(
                                    future: receiver
                                        .collection('account_type')
                                        .doc('patrone')
                                        .get(),
                                    builder: (context, senderSnapshot) {
                                      if (senderSnapshot.hasData) {
                                        Map<String, dynamic>? senderData =
                                            senderSnapshot.data?.data()
                                                as Map<String, dynamic>?;
                                        return ListTile(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConversationScreen(
                                                          chats: messages![index]
                                                              .reference))),
                                          leading: GestureDetector(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Scaffold(
                                                            appBar: AppBar(
                                                              title: Text(
                                                                  '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}'),
                                                            ),
                                                            body:
                                                            FutureBuilder<Patrone>(
                                                              future: Patrone()
                                                                  .getPatroneInformation(receiver
                                                                  .collection(
                                                                  'account_type')
                                                                  .doc(
                                                                  'patrone')),
                                                              builder: (context, snapshot) {
                                                                return ProfileScreen(
                                                                    userProfile: snapshot.data!);
                                                              }
                                                            )))),
                                            child: CircleAvatar(
                                              radius: 30,
                                              foregroundImage: NetworkImage(
                                                  senderData!['profile_picture'] ?? 'https://i.pinimg.com/564x/7c/2a/3f/7c2a3fd9895fbfcc949d7af23d276b09.jpg'),
                                            ),
                                          ),
                                          title: Text(
                                              '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}',
                                              style: const TextStyle(
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
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    });
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
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
      ),
    );
  }
}
