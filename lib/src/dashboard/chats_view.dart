import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';

import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'conversation_screen.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key, required this.chatType});

  final ChatRoomType chatType;

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final messagesCollection = firestore.collection('messages').where(
      'participants',
      arrayContains: Patrone().currentUserPatroneProfile);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: height(context),
        width: width(context),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: messagesCollection.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                List<DocumentSnapshot> messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                      child: Text(
                          'You have no messages. Start a new conversation'));
                }

                log(messages.toString());
                log(messages.length.toString());
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> messageData =
                              messages[index].data() as Map<String, dynamic>;
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
                                      future: receiver.get(),
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
                                                            chats: messages[
                                                                    index]
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
                                                              body: FutureBuilder<
                                                                      Patrone>(
                                                                  future: Patrone().getPatroneInformation(receiver
                                                                      .collection(
                                                                          'account_type')
                                                                      .doc(
                                                                          'patrone')),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return const Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    }
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      return Center(
                                                                          child:
                                                                              Text('Error: ${snapshot.error}'));
                                                                    }
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return const Center(
                                                                          child:
                                                                              Text('No data available'));
                                                                    }
                                                                    return ProfileScreen(
                                                                        userProfile:
                                                                            snapshot.data!);
                                                                  })))),
                                              child: CircleAvatar(
                                                radius: 30,
                                                foregroundImage: NetworkImage(
                                                    senderData![
                                                            'profile_picture'] ??
                                                        'https://i.pinimg.com/564x/7c/2a/3f/7c2a3fd9895fbfcc949d7af23d276b09.jpg'),
                                              ),
                                            ),
                                            title: Text(
                                                '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(
                                                '${lastMessageData?['senderID'] == currentUserProfile ? 'You: ' : ''}${lastMessageData?['content'] ?? 'test'}'),
                                            trailing: Text(DateFormat('HH:mm')
                                                .format((lastMessageData?[
                                                            'time_sent']
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
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.messenger),
            onPressed: () async => _showUsersDialog(),
            label: const Text('Start a new chat'),
          ),
        ),
      ),
    ]);
  }

  Future<void> _showUsersDialog() async {
    // Fetch users from Firebase
    final usersSnapshot =
        await FirebaseFirestore.instance.collectionGroup('account_type').get();

    // Extract user data
    final users = usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'ref': doc.reference,
        'name':
            '${data['first_name'] ?? 'User'} ${data['last_name'] ?? 'Name'}',
        'profilePicture': data['profile_picture'] ??
            'https://i.pinimg.com/736x/e8/d7/d0/e8d7d05f392d9c2cf0285ce928fb9f4a.jpg',
      };
    }).toList();

    // Check if widget is still mounted before showing the dialog
    if (!mounted) return;

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a user to chat with'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePicture']),
                ),
                title: Text(user['name']),
                onTap: () {
                  Navigator.pop(context);
                  _startChat(user['ref']);
                },
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startChat(user['ref']);
                  },
                  child: Text('Chat'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _startChat(DocumentReference receiverRef) {
    print('Start chat with user: ${receiverRef.id}');
    FirebaseFirestore.instance.collection('messages').add({
      'participants': [receiverRef, Patrone().currentUserPatroneProfile]
    }).then((chatRef) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationScreen(chats: chatRef),
        ),
      );
    });
  }
}
