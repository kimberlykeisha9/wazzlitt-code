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
    return Center(
      child: Container(
        color: Theme.of(context).canvasColor,
        height: height(context),
        width: width(context),
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('feed')
                .where('image', isNotEqualTo: null)
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
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                    maxHeight: (height(context) * 0.9),
                                    minHeight: 300),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: FeedImage(snapshot: doc)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
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
        ),
      ),
    );
  }
}
