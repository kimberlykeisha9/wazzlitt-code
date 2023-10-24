import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey key = GlobalKey();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context),
      width: width(context),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('feed').where('image', isNotEqualTo: null)
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
                  itemCount: feedData.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot doc = feedData[index];
                    if (snapshot.data!.size > 0) {
                      return Container(constraints: BoxConstraints(maxHeight: height(context), minHeight: 300) ,child: FeedImage(snapshot: doc));
                    } else {
                      return const Center(
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
