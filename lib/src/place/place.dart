import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wazzlitt/src/dashboard/conversation_screen.dart';
import 'package:wazzlitt/src/location/location.dart';
import '../app.dart';
import 'place_order.dart';

class Place extends StatefulWidget {
  Place({super.key, required this.place});

  final Map<String, dynamic> place;

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  late GoogleMapController mapController;

  static LatLng _initialPosition = LatLng(37.7749, -122.4194);

  // Future<int> inRadius() {

  Stream<List<DocumentSnapshot<Object?>>>? nearby;

  // Set your Google Maps API key here.
  final String apiKey = "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GeoPoint location = widget.place['location']['geopoint'];
    _initialPosition = LatLng(location.latitude, location.longitude);
    nearby = getNearbyPeople(_initialPosition.latitude, _initialPosition
        .longitude);
  }

  void _shareOnFacebook() {
    Share.share('Shared on Facebook');
  }

  void _shareOnTwitter() {
    Share.share('Shared on Twitter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place['place_name'] ?? 'Null'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share on social media'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.facebook),
                        title: const Text('Share on Facebook'),
                        onTap: () {
                          // Implement Facebook sharing logic here
                          _shareOnFacebook();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.twitter),
                        title: const Text('Share on Twitter'),
                        onTap: () {
                          // Implement Twitter sharing logic here
                          _shareOnTwitter();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                      // Add more social media sharing options as needed
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Container(
                      width: width(context),
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          image: widget.place.containsKey('cover_image')
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    widget.place['cover_image'],
                                  ),
                                )
                              : null),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                            image: widget.place.containsKey('image')
                                ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.place['image'],
                              ),
                            )
                                : null
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(widget.place['place_name'] ?? 'Null',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    Chip(label: Text(widget.place['category'] ?? 'Null')),
                    Text('Open - ${DateFormat('hh:mm a').format(((widget.place['opening_time']) as Timestamp).toDate())} to ${DateFormat('hh:mm a').format(((widget.place['closing_time']) as Timestamp).toDate())}'),
                    const SizedBox(height: 5),
                    StreamBuilder<List<DocumentSnapshot>>(
                      stream: nearby,
                      builder: (context, snapshot) {
                        return Text('${snapshot.data?.length ?? 0} Patrones '
                            'around here',
                            style: TextStyle(fontWeight: FontWeight.bold));
                      }
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5)),
                              onPressed: () {},
                              child: const Text('Follow',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5)),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chats: widget.place['chat_room']))),
                              child: const Text('Chat Room',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5)),
                              onPressed: () {},
                              child: const Text('Contact',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text('About ${widget.place['place_name'] ?? 'Null'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          const SizedBox(height: 10),
                          Text(widget.place['place_description'],
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    widget.place.containsKey('services') ? TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceOrder(
                                place: widget.place),
                          ),
                        );
                      },
                      child: const Text('Check out our services'),
                    ) : const SizedBox(),
                    widget.place.containsKey('services') ? const SizedBox(height: 10) : const SizedBox(),
                    const Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Street Name', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: width(context),
                height: 100,
                color: Colors.grey,
                child: GoogleMap(
                  markers: {
                    Marker(markerId: MarkerId('place'), position: _initialPosition)
                  },
                  initialCameraPosition: CameraPosition(target:
                  _initialPosition, zoom: 12),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: Column(
              //     children: [
              //       const Text('Photos',
              //           style: TextStyle(fontWeight: FontWeight.bold)),
              //       SizedBox(
              //           height: 20,
              //           child: TextButton(
              //               style: TextButton.styleFrom(
              //                   padding: const EdgeInsets.all(0)),
              //               onPressed: () {},
              //               child: const Text('See more',
              //                   style: TextStyle(fontSize: 12)))),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: 400,
              //   width: width(context),
              //   child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: 4,
              //       itemBuilder: (context, index) {
              //         return Container(
              //           width: width(context) * 0.25,
              //           color: Colors.grey,
              //         );
              //       }),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
