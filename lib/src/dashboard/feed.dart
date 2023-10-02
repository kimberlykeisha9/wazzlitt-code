import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../app.dart';
import 'feed_image.dart';

class Feed extends StatefulWidget {
  const Feed({
    super.key,
  });

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height(context),
      width: width(context),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('feed')
            .orderBy('date_created', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Object?>>? feedData =
                snapshot.data!.docs;
            return SizedBox(
              height: height(context),
              width: width(context),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: feedData?.length ?? 0,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot doc = feedData[index];
                    if (snapshot.data!.size > 0) {
                      return FadeIn(child: FeedImage(snapshot: doc));
                    } else {
                      return Center(
                          child: Text('No images have been posted yet'));
                    }
                  }),
            );
          } else {
            return const Center(child: Text('Nothing to see here'));
          }
        },
      ),
    );
  }
}
