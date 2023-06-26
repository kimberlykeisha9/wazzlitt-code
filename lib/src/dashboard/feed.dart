import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import 'feed_image.dart';

class Feed extends StatefulWidget {
  Feed({
    super.key,
  });

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<QueryDocumentSnapshot<Object?>>? _feedData = [];
  List<PostData>? _posts = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: firestore.collection('feed').orderBy('date_created',
          descending: true).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
            _feedData = snapshot.data?.docs;
            _feedData?.forEach((doc) {
              _posts?.add(PostData(postImage: doc.get('image'), caption: doc
                  .get('caption'),
                timeCreated: doc.get('date_created'), likes: doc.get('likes'),
                location:
                doc.get('location'),
                postCreator: doc.get('creator_uid'),),);
            });
          return PageView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: _feedData?.length ?? 0,
            itemBuilder: (context, index) {
              return FeedImage(postData: _posts![index],);
            },
          );
        } else {
          return Center(child: Text('Nothing to see here'));
        }
      },
    );
  }
}
