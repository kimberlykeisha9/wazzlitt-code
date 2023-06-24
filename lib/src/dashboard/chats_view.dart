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
  firestore.collection('chats').where('participants', arrayContains:
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
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot messageSnapshot = messages[index];
              Map<String, dynamic> messageData = messageSnapshot.data() as Map<String, dynamic>;

              // Extract the message details from the messageData map
              String senderId = messageData['senderId'];
              String content = messageData['content'];
              Timestamp timestamp = messageData['timestamp'];

              // Display the message using a ListTile or any other widget
              return ListTile(
                title: Text(content),
                // subtitle: Text('Sender: $senderId'),
                // trailing: Text('Time: ${timestamp.toDate().toString()}'),
              );
            },
          );
        },
      ),
    );
  }
}
