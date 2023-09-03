import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wazzlitt/src/dashboard/conversation_screen.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import '../app.dart';

class Place extends StatefulWidget {
  Place({Key? key, required this.place}) : super(key: key);

  final BusinessPlace place;

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  late GoogleMapController mapController;

  static LatLng _initialPosition = const LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    GeoPoint location = widget.place.location ?? const GeoPoint(0, 0);
    _initialPosition = LatLng(location.latitude, location.longitude);
  }

  void _shareOnFacebook() {
    Share.share('Shared on Facebook');
  }

  void _shareOnTwitter() {
    Share.share('Shared on Twitter');
  }

  Set<Marker> patroneMarkers = {};

  Widget _buildHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            width: width(context),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: widget.place.coverImage != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.place.coverImage!),
                    )
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
                image: widget.place.image != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.place.image!),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.place.placeName ?? 'Null',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Chip(label: Text(widget.place.category ?? 'Unknown')),
          Text(
            'Open - ${DateFormat('hh:mm a').format(widget.place.openingTime ?? DateTime(0, 0, 0, 0, 0))} to ${DateFormat('hh:mm a').format(widget.place.closingTime ?? DateTime(0, 0, 0, 0, 0))}',
          ),
          const SizedBox(height: 5),
          StreamBuilder<List<DocumentSnapshot>>(
            stream: getNearbyPeople(
                _initialPosition.latitude, _initialPosition.longitude),
            builder: (context, snapshot) {
              final patroneCount = snapshot.data?.length ?? 0;
              return Text(
                '$patroneCount Patrones around here',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 30),
          widget.place.placeReference != null
              ? Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () {},
                          child: const Text(
                            'Follow',
                            style: TextStyle(fontSize: 12),
                          ),
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                chats: widget.place.chatroom!,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Chat Room',
                            style: TextStyle(fontSize: 12),
                          ),
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
                          child: const Text(
                            'Contact',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    'This place is not officially listed on WazzLitt, so no chatrooms are currently available',
                  ),
                ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'About ${widget.place.placeName ?? 'Null'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.place.description ?? 'No description available',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          widget.place.placeReference != null
              ? widget.place.services != null
                  ? TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => PlaceOrder(
                        //       place: widget.place.placeReference!,
                        //     ),
                        //   ),
                        // );
                      },
                      child: const Text('Check out our services'),
                    )
                  : const SizedBox()
              : const SizedBox(),
          widget.place.services != null
              ? const SizedBox(height: 10)
              : const SizedBox(),
          const Text(
            'Location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      width: width(context),
      height: 250,
      color: Colors.grey,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Container(
              height: height(context) * 0.9,
              width: width(context) * 0.9,
              child: GoogleMap(
                markers: {
                  Marker(
                      markerId: const MarkerId('place'),
                      position: _initialPosition),
                  ...patroneMarkers
                },
                initialCameraPosition:
                    CameraPosition(target: _initialPosition, zoom: 12),
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),
            ),
          );
        },
        child: GoogleMap(
          markers: {
            Marker(
                markerId: const MarkerId('place'), position: _initialPosition),
            ...patroneMarkers
          },
          initialCameraPosition:
              CameraPosition(target: _initialPosition, zoom: 12),
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.placeName ?? 'Null'),
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
                          _shareOnFacebook();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.twitter),
                        title: const Text('Share on Twitter'),
                        onTap: () {
                          _shareOnTwitter();
                          Navigator.pop(context);
                        },
                      ),
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
              _buildHeader(),
              _buildInfo(),
              _buildMap(),
            ],
          ),
        ),
      ),
    );
  }
}
