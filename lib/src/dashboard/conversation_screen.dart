import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';

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
    return FutureBuilder<DocumentSnapshot>(
        future: widget.chats.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> chatsInfo = snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
              appBar: AppBar(title: const Text('Conversation'), actions: [
                IconButton(
                    icon: const Icon(Icons.account_circle), onPressed: () {})
              ]),
              body: Column(
                children: [
                  chatsInfo.containsKey('identifier') ? FutureBuilder<DocumentSnapshot>(
                    future: chatsInfo['owner'].get(),
                    builder: (context, snapshot) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage((snapshot.data!.data() as Map<String, dynamic>?)?['image'] ?? 'https://i.pinimg.com/564x/60/9a/37/609a375345b463141ec4c875ee2f1104.jpg'),

                          ),
                        ),
                        child: Column(
                          children: [
                            Text(chatsInfo['welcome_message']),
                            SizedBox(height: 5),
                            Text('All chats older than 24 hours are cleared automatically'),
                          ],
                        )
                      );
                    }
                  ) : SizedBox(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: widget.chats
                            .collection('chats')
                            .orderBy('time_sent')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<QueryDocumentSnapshot<Object?>> chats =
                                snapshot.data!.docs;
                            print(chats.length);
                            return SafeArea(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: chats.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return FutureBuilder<DocumentSnapshot>(
                                        future: chats[index].reference.get(),
                                        builder: (context, messageSnapshot) {
                                          Map<String, dynamic> message =
                                          messageSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                          print('This is the message: $message');
                                          bool isUser =
                                              message['senderID'] == currentUserProfile;
                                          return FutureBuilder<DocumentSnapshot>(
                                              future: message['senderID']
                                                  .collection('account_type')
                                                  .doc('patrone')
                                                  .get(),
                                              builder: (context, senderSnapshot) {
                                                if (senderSnapshot.hasData) {
                                                  Map<String, dynamic> senderData =
                                                  senderSnapshot.data?.data()
                                                  as Map<String, dynamic>;
                                                  return ListTile(
                                                    contentPadding:
                                                    const EdgeInsets.all(10),
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
                                                                        future:
                                                                        Patrone().getPatroneInformation((message[
                                                                        'senderID']
                                                                        as DocumentReference)
                                                                            .collection(
                                                                            'account_type')
                                                                            .doc(
                                                                            ''
                                                                                'patrone')),
                                                                        builder: (context, snapshot) {
                                                                          return ProfileScreen(
                                                                              userProfile: snapshot.data!);
                                                                        }
                                                                      )))),
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        foregroundImage: NetworkImage(
                                                            senderData['profile_picture']),
                                                      ),
                                                    ),
                                                    tileColor: isUser
                                                        ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.25)
                                                        : null,
                                                    title: Text(
                                                        '${senderData['first_name'] ?? ''} ${senderData['last_name'] ?? ''}',
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold)),
                                                    subtitle: Text(message['content']),
                                                    trailing: Text(DateFormat('HH:mm')
                                                        .format((message['time_sent']
                                                    as Timestamp)
                                                        .toDate())),
                                                  );
                                                }
                                                return const Center(
                                                    child: CircularProgressIndicator());
                                              });
                                        });
                                  },
                                ));
                          }
                          return const Center(child: CircularProgressIndicator());
                        }),
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
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Send a message...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        sendMessage(widget.chats.collection('chats'),
                            messageController.text)
                            .then((value) => messageController.clear());
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
