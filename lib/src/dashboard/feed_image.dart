import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
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

  PostData(
      {required this.postImage,
      required this.caption,
      required this.timeCreated,
      required this.likes,
      required this.location,
      required this.postCreator});
}

class Creator {
  String? creatorImage;
  String creatorUsername;

  Creator({required this.creatorImage, required this.creatorUsername});
}

class FeedImage extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const FeedImage({super.key, required this.snapshot});

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage>
    with SingleTickerProviderStateMixin {
  String? location;
  String popUpValue = '';
  Future<String> getLocationFromGeoPoint(GeoPoint geoPoint) async {
    try {
      // Reverse geocode the latitude and longitude
      const String googelApiKey = 'AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ';
      final bool isDebugMode = true;
      final api = GoogleGeocodingApi(googelApiKey, isLogged: isDebugMode);
      final reversedSearchResults = await api.reverse(
        '${geoPoint.latitude},${geoPoint.longitude}',
        language: 'en',
      );

      if (reversedSearchResults.results.isNotEmpty) {
        String readableLocation =
            reversedSearchResults.results.first.formattedAddress;

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
    getLocationFromGeoPoint(widget.snapshot.get('location'))
        .then((value) => location = value);
    super.initState();
  }

  Widget likeIcon() {
    List<dynamic> likes = widget.snapshot.get('likes');
    if (likes.contains(currentUserProfile)) {
      return const Icon(Icons.favorite, color: Colors.red);
    } else {
      return const Icon(Icons.favorite_outline, color: Colors.white);
    }
  }

  Future<void> _likeImage() async {
    List<dynamic> likes = widget.snapshot.get('likes');
    if (likes.contains(currentUserProfile)) {
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
            Map<String, dynamic> imageData =
                snapshot.data!.data() as Map<String, dynamic>;
            return Container(
              constraints: const BoxConstraints(maxWidth: 400),
              alignment: Alignment.topCenter,
              child: Wrap(
                direction: Axis.vertical,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                      stream: (imageData['creator_uid'] as DocumentReference)
                          .snapshots(),
                      builder: (context, creatorSnapshot) {
                        if (creatorSnapshot.hasData) {
                          Map<String, dynamic> data = creatorSnapshot.data!
                              .data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                        title:
                                            Text(data['username'] ?? 'null')),
                                    body: FutureBuilder<Patrone>(
                                        future: Patrone().getPatroneInformation(
                                            widget.snapshot.get('creator_uid')),
                                        builder: (context, snapshot) {
                                          return ProfileScreen(
                                              userProfile: snapshot.data!);
                                        }),
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
                                      foregroundImage: NetworkImage(data[
                                              'profile_picture'] ??
                                          'https://i.pinimg.com/474x/1e/23/e5/1e23e5e6441ce2c135e1e457dcf4f06f.jpg'),
                                      radius: 20,
                                      child: (data['profile_picture']) != null
                                          ? null
                                          : const Icon(
                                              Icons.account_circle,
                                              size: 40,
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Wrap(
                                      direction: Axis.vertical,
                                      alignment: WrapAlignment.start,
                                      children: [
                                        Text(data['username'] ?? 'null',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(location ?? '',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    const Spacer(),
                                    PopupMenuButton(
                                      itemBuilder: (context) {
                                        return [
                                          const PopupMenuItem(
                                            value: 'report',
                                            child: Text('Report'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'block',
                                            child: Text('Block User'),
                                          ),
                                        ];
                                      },
                                      onSelected: (value) {
                                        setState(() {
                                          popUpValue = value;
                                          if (value == 'report') {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  title: const Text(
                                                      'Make a Report'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      DropdownButtonFormField<
                                                          String>(
                                                        value: selectedReason,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            selectedReason =
                                                                newValue;
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Reason for Report',
                                                          // border: OutlineInputBorder(),
                                                        ),
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value: 'Spam',
                                                            child: Text('Spam'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'Harassment',
                                                            child: Text(
                                                                'Harassment'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value:
                                                                'Inappropriate Content',
                                                            child: Text(
                                                                'Inappropriate Content'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'Other',
                                                            child:
                                                                Text('Other'),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      TextFormField(
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Any further information?'),
                                                        minLines: 1,
                                                        maxLines: 5,
                                                      )
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {},
                                                        child: const Text(
                                                            'Submit Report'))
                                                  ]),
                                            );
                                          } else if (value == 'block') {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  title:
                                                      const Text('Block User'),
                                                  content: const Text(
                                                      'Are you sure you want to block this user?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Yes, I am sure'),
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
                                      },
                                    ),
                                  ]),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: height(context) * 0.6,
                        minWidth: width(context)),
                    // child: Image.network(
                    //     imageData['image'],
                    //     fit: BoxFit.fitWidth),
                    child: Image.asset('assets/images/home-image.png',
                        fit: BoxFit.fitWidth),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                                (widget.snapshot.get('caption') as String?) ??
                                    '',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          Row(children: [
                            IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () => _likeImage(),
                              icon: likeIcon(),
                            ),
                            Text(
                                '${(imageData['likes'] as List<dynamic>).length ?? 0}',
                                style: const TextStyle(color: Colors.white)),
                            IconButton(
                              onPressed: () {},
                              icon: const FaIcon(FontAwesomeIcons.message,
                                  color: Colors.white),
                            ),
                            const Text('0',
                                style: TextStyle(color: Colors.white)),
                          ]),
                          Text(
                              DateFormat('hh:mm, EEE d MMM').format(
                                  (imageData['date_created'] as Timestamp)
                                      .toDate()),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
