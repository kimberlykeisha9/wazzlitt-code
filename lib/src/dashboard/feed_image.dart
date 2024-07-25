import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../../user_data/patrone_data.dart';
import '../app.dart';

class PostData {
  String postImage;
  String caption;
  Timestamp timeCreated;
  List likes;
  DocumentReference postCreator;
  GeoPoint location;

  PostData({
    required this.postImage,
    required this.caption,
    required this.timeCreated,
    required this.likes,
    required this.location,
    required this.postCreator,
  });
}

class Creator {
  String? creatorImage;
  String creatorUsername;

  Creator({required this.creatorImage, required this.creatorUsername});
}

class FeedImage extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const FeedImage({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage>
    with SingleTickerProviderStateMixin {
  String? location;

  Future<String> getLocationFromGeoPoint(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street ?? ''}, ${placemark.country ?? ''}';
      }
    } catch (e) {
      log('Error: $e');
    }
    return '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final geoPoint = widget.snapshot.get('location') as GeoPoint;
    getLocationFromGeoPoint(geoPoint).then((value) {
      if (mounted) {
        setState(() {
          location = value;
        });
      }
    });
  }

  Widget likeIcon(List<dynamic> likes) {
    return Icon(
      likes.contains(currentUserProfile)
          ? Icons.favorite
          : Icons.favorite_outline,
      color: likes.contains(currentUserProfile) ? Colors.red : Colors.white,
    );
  }

  Future<void> _likeImage() async {
    final List<dynamic> likes = widget.snapshot.get('likes');
    final isLiked = likes.contains(currentUserProfile);
    await widget.snapshot.reference.update({
      'likes': isLiked
          ? FieldValue.arrayRemove([currentUserProfile])
          : FieldValue.arrayUnion([currentUserProfile]),
    });
  }

  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.snapshot.reference.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrl = data['image'] as String?;
        final caption = data['caption'] as String?;
        final likes = data['likes'] as List<dynamic>;
        final creatorRef = data['creator_uid'] as DocumentReference;
        final dateCreated = (data['date_created'] as Timestamp).toDate();

        return Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: width(context),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imageUrl ??
                          'https://i.pinimg.com/736x/7f/ab/d5/7fabd5ce19ca27ef39431c63fd786521.jpg'),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: width(context),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.75),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              location ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                caption ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _likeImage,
                                  icon: likeIcon(likes),
                                ),
                                Text(
                                  '${likes.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const FaIcon(
                                    FontAwesomeIcons.message,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  '0',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: creatorRef.snapshots(),
                        builder: (context, creatorSnapshot) {
                          if (creatorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          } else if (creatorSnapshot.hasError) {
                            return const SizedBox();
                          } else if (!creatorSnapshot.hasData) {
                            return const SizedBox();
                          }

                          final creatorData = creatorSnapshot.data!.data()
                              as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(
                                          creatorData['username'] ?? 'null'),
                                    ),
                                    body: FutureBuilder<Patrone>(
                                      future: Patrone().getPatroneInformation(
                                        widget.snapshot.get('creator_uid'),
                                      ),
                                      builder: (context, profileSnapshot) {
                                        if (!profileSnapshot.hasData) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        return ProfileScreen(
                                          userProfile: profileSnapshot.data!,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
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
                                      creatorData['profile_picture'] ??
                                          'https://i.pinimg.com/474x/1e/23/e5/1e23e5e6441ce2c135e1e457dcf4f06f.jpg',
                                    ),
                                    radius: 20,
                                    child:
                                        creatorData['profile_picture'] == null
                                            ? const Icon(Icons.account_circle,
                                                size: 40)
                                            : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Wrap(
                                    direction: Axis.vertical,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text(
                                        creatorData['username'] ?? 'null',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('hh:mm, EEE d MMM')
                                            .format(dateCreated),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onPressed: () => showPopupMenu(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        const PopupMenuItem(value: 'report', child: Text('Report')),
        const PopupMenuItem(value: 'block', child: Text('Block User')),
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
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Spam', child: Text('Spam')),
                    DropdownMenuItem(
                        value: 'Harassment', child: Text('Harassment')),
                    DropdownMenuItem(
                        value: 'Inappropriate Content',
                        child: Text('Inappropriate Content')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Any further information?'),
                  minLines: 1,
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Submit Report'),
              ),
            ],
          ),
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
            ],
          ),
        );
      }
    });
  }
}
