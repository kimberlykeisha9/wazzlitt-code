import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../user_data/user_data.dart';
import '../../app.dart';
import '../../event/edit_event_organizer.dart';
import '../../place/edit_place.dart';
import '../../place/service_overview.dart';

class EventOrganizerProfile extends StatelessWidget {
  EventOrganizerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: SizedBox(
                width: width(context),
                height: height(context),
                child: FutureBuilder<DocumentSnapshot>(
                    future: currentUserIgniterProfile.get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> eventOrganizerData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
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
                                      image:
                                          eventOrganizerData['cover_image'] ==
                                                  null
                                              ? null
                                              : DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      eventOrganizerData[
                                                          'cover_image'])),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Hero(
                                      tag: 'profile',
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[800],
                                          shape: BoxShape.circle,
                                          image: eventOrganizerData['image'] ==
                                                  null
                                              ? null
                                              : DecorationImage(
                                                  image: NetworkImage(
                                                      eventOrganizerData[
                                                          'image'])),
                                        ),
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
                                  Text(
                                      eventOrganizerData['organizer_name'] ??
                                          'null',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const SizedBox(height: 20),
                                  const Text('0 Followers'),
                                  const SizedBox(height: 10),
                                  const Text('97% Popularity'),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
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
                                                builder: (context) =>
                                                    EditEventOrganizer(),
                                              ),
                                            ),
                                            child: const Text('Edit Profile',
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
                                                padding:
                                                    const EdgeInsets.all(5)),
                                            onPressed: () {},
                                            child: const Text('Social Links',
                                                style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('About Us',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextButton(
                                          child: const Text(''),
                                          onPressed: () {},
                                        )
                                      ]),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      eventOrganizerData[
                                              'organizer_description'] ??
                                          'null',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Tagged Photos',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  TextButton(
                                    child: const Text('Tap to review'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 150,
                              width: width(context),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: 4,
                                itemBuilder: (context, index) => Container(
                                  height: 150,
                                  width: width(context) * 0.25,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }))));
  }
}
