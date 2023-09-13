import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/event/edit_event.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';

import '../../../user_data/user_data.dart';
import '../../app.dart';
import '../../event/edit_event_organizer.dart';

class EventOrganizerProfile extends StatelessWidget {
  const EventOrganizerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final eventOrganizer = Provider.of<EventOrganizer>(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          height: height(context),
          width: width(context),
          decoration: BoxDecoration(
            image: moon,
          ),
          child: FutureBuilder<void>(
            future: eventOrganizer.getCurrentUserEventOrganizerInformation(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final events = eventOrganizer.events;
                final coverImage = eventOrganizer.coverImage;
                final organizerName = eventOrganizer.organizerName;
                final profileImage = eventOrganizer.profileImage;
                final description = eventOrganizer.description;
                final website = eventOrganizer.website;
                final phone = eventOrganizer.phone;
                final email = eventOrganizer.email;

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
                              image: coverImage == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(coverImage!)),
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
                                  image: profileImage == null
                                      ? null
                                      : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(profileImage)),
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
                          Text(organizerName ?? 'null',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
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
                                            const EditEventOrganizer(),
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
                                        padding: const EdgeInsets.all(5)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('About Us',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextButton(
                                  child: const Text(''),
                                  onPressed: () {},
                                )
                              ]),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              description ?? 'null',
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Posted Events',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          TextButton(
                            child: const Text('Create new event'),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const EditEvent()));
                            },
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: events?.length,
                      itemBuilder: (context, index) {
                        EventData? event = events?[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditEvent(
                                        event: event.eventReference!)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: DecorationImage(
                                colorFilter:
                                    event!.date!.isBefore(DateTime.now())
                                        ? const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.saturation,
                                          )
                                        : null,
                                fit: BoxFit.cover,
                                image: NetworkImage(event.image!),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(event.eventName ?? 'null',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
