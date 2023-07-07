import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../app.dart';

class PostData {
  String postImage;
  String caption;
  Timestamp timeCreated;
  List likes;
  DocumentReference postCreator;
  GeoPoint location;

  PostData({required this.postImage, required this.caption, required this
      .timeCreated, required this.likes, required this.location, required
  this.postCreator});
}

class Creator {
  String? creatorImage;
  String creatorUsername;

  Creator({required this.creatorImage, required this.creatorUsername});
}

class FeedImage extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const FeedImage({
    super.key, required this.snapshot
  });

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage> {
  String? location;
  Future<String> getLocationFromGeoPoint(GeoPoint geoPoint) async {
    try {
      // Reverse geocode the latitude and longitude
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String readableLocation = placemark.locality ?? placemark.administrativeArea ?? '';

        return readableLocation;
      }
    } catch (e) {
      log('Error: $e');
    }

    return '';
  }

  @override
  void initState() {
    // TODO: implement initState
      getLocationFromGeoPoint(widget.snapshot.get('location')).then((value) => location = value);
    super.initState();
  }

  Widget likeIcon() {
    List<dynamic> likes = widget.snapshot.get('likes');
    if(likes.contains(currentUserProfile)) {
      return const Icon(Icons.favorite, color: Colors.red);
    } else {
      return const Icon(Icons.favorite_outline, color: Colors.white);
    }
  }

  Future<void> _likeImage() async {
    List<dynamic> likes = widget.snapshot.get('likes');
    if(likes.contains(currentUserProfile)) {
      await widget.snapshot.reference.update({
        'likes': FieldValue.arrayRemove([currentUserProfile])
      });
    } else {
      await widget.snapshot.reference.update({
        'likes': FieldValue.arrayUnion([currentUserProfile])
      });
    }
  }
  String? selectedReason;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.snapshot.reference.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  width: width(context),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data!.get('image'))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text((widget.snapshot.get('caption') as
                              String?) ?? '',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => _likeImage(),
                                  icon: likeIcon(),
                                ),
                                Text('${(snapshot.data!.get('likes') as
                                List<dynamic>)
              .length ??
                                    '0'}',
                                    style:
                                const TextStyle
                                  (color: Colors
                                    .white)),
                                IconButton(
                                  onPressed: () {},
                                  icon: const FaIcon(FontAwesomeIcons.message,
                                      color: Colors.white),
                                ),
                                const Text('0', style: TextStyle(color: Colors.white)),
                              ]
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: (widget.snapshot.get('creator_uid') as
                        DocumentReference).collection('account_type').doc
                          ('patrone')
                            .snapshots(),
                        builder: (context, creatorSnapshot) {
                          if (creatorSnapshot.hasData) {
                            return Container(
                              width: width(context),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.25),
                              ),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      foregroundImage: NetworkImage(
                                          (creatorSnapshot.data!.get
                                        ('profile_picture') as
                                      String)),
                                      radius: 20,
                                      child:(creatorSnapshot.data?.get
                                        ('profile_picture') as
                                      String?) !=
                                          null ? null :
                                      const Icon(Icons
                                          .account_circle, size: 40,),
                                    ),
                                    const SizedBox(width: 10),
                                    Wrap(
                                      direction: Axis.vertical,
                                      alignment: WrapAlignment.start,
                                      children: [
                                        Text((creatorSnapshot.data!.get
                                          ('username') as
                                        String?)
                                            ?? 'null',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(DateFormat('hh:mm, EEE d MMM').format
                                          ((widget.snapshot.get
                                          ('date_created') as
                                        Timestamp).toDate()),
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 14)),
                                      ],
                                    ),
                                    const Spacer(),

                                    IconButton(
                                      icon:
                                          const Icon(Icons.more_vert, color: Colors.white),
                                      onPressed: () {
                                        showPopupMenu(context);
                                      },
                                    ),
                                  ]),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: width(context),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.75),
                        ),
                        child:  Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white),
                            const Spacer(),
                            Text(location ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const Spacer(flex: 16),
                            const Text('0 km away', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (
        snapshot.hasError
        ) {
          return const Center(child: Text('Something went wrong'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  void showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = Offset(overlay.size.width / 2, overlay.size.height);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'report',
          child: Text('Report'),
        ),
        const PopupMenuItem(
          value: 'block',
          child: Text('Block User'),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value == 'report') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Make a Report'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReason = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Reason for Report',
                      // border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Spam',
                        child: Text('Spam'),
                      ),
                      DropdownMenuItem(
                        value: 'Harassment',
                        child: Text('Harassment'),
                      ),
                      DropdownMenuItem(
                        value: 'Inappropriate Content',
                        child: Text('Inappropriate Content'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Any further information?'),
                    minLines: 1,
                    maxLines: 5,
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Submit Report'))
              ]),
        );
      } else if (value == 'block') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Block User'),
              content: const Text('Are you sure you want to block this user?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Yes, I am sure'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ]),
        );
      }
    });
  }
}
