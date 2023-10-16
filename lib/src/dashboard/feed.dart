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

  void initTargets() {
    void addToTarget(GlobalKey assignedKey, String target, String instruction) {
      targets.add(
        TargetFocus(
          identify: target,
          keyTarget: assignedKey,
          color: Colors.red,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      instruction,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
    }

    addToTarget(key, '1', 'Browse the feed');
  }

  void showTutorial(BuildContext context) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.pink,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        log("finish");
      },
      onClickTarget: (target) {
        log('onClickTarget: $target');
      },
      onSkip: () {
        log("skip");
      },
      onClickOverlay: (target) {
        log('onClickOverlay: $target');
      },
    )..show(context: context);
  }

  void _layout(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100));
    showTutorial(context);
  }

  @override
  void initState() {
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _layout(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  prototypeItem: Container(),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: feedData.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot doc = feedData[index];
                    if (snapshot.data!.size > 0) {
                      return FadeIn(child: FeedImage(snapshot: doc));
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
