import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import 'feed_image.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context),
      width: width(context),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feed')
            .orderBy('date_created', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (snapshot.hasData) {
            final feedData = snapshot.data!.docs;

            if (feedData.isEmpty) {
              return const Center(
                  child: Text('No images have been posted yet'));
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: feedData.length,
              itemBuilder: (context, index) {
                final doc = feedData[index];
                return FadeIn(child: FeedImage(snapshot: doc));
              },
            );
          } else {
            return const Center(child: Text('Nothing to see here'));
          }
        },
      ),
    );
  }
}
