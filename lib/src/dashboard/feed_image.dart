import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../app.dart';

class PostData {
  String? postImage;
  String? caption;
  Timestamp? timeCreated;
  List? likes;
  DocumentReference? postCreator;
  GeoPoint? location;

  PostData({required this.postImage, required this.caption, required this
      .timeCreated, required this.likes, required this.location, required
  this.postCreator});
}

class Creator {
  String? creatorImage;
  String? creatorUsername;

  Creator({required this.creatorImage, required this.creatorUsername});
}

class FeedImage extends StatefulWidget {
  PostData postData;

  FeedImage({
    super.key, required this.postData
  });

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage> {
  Creator? creator;
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
    super.initState();
    if (widget.postData.location != null) {
      getLocationFromGeoPoint(widget.postData.location!).then((value) => location = value);
    }
    widget.postData.postCreator?.collection('account_type').doc('patrone').get()
        .then((data)
    => {
      creator = Creator(
        creatorImage: data.get('profile_picture'),
        creatorUsername: data.get('username'),
      )
    });
  }
  String? selectedReason;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: width(context),
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.postData.postImage!)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(widget.postData.caption ?? '',
                      style: TextStyle(color: Colors.white)),
                ),
                Container(
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
                          radius: 20,
                          child: creator?.creatorImage !=
                              null ? Image.network(creator!.creatorImage!) :
                          Icon(Icons
                              .account_circle)
                        ),
                        SizedBox(width: 10),
                        Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.start,
                          children: [
                            Text(creator?.creatorUsername
                                ?? '@null',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(DateFormat('hh:mm, EEE d MMM').format
                              (widget.postData.timeCreated!.toDate()) ?? '',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(
                            FontAwesomeIcons.heart,
                            color: Colors.white,
                          ),
                        ),
                        Text('${widget.postData.likes?.length ?? '0'}', style:
                        TextStyle
                          (color: Colors
                            .white)),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(FontAwesomeIcons.message,
                              color: Colors.white),
                        ),
                        const Text('0', style: TextStyle(color: Colors.white)),
                        IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            showPopupMenu(context);
                          },
                        ),
                      ]),
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
                      Icon(Icons.place, color: Colors.white),
                      Spacer(),
                      Text(location ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Spacer(flex: 16),
                      Text('0 km away', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
