import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/event/event.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';

import '../../user_data/patrone_data.dart';
import '../app.dart';
import '../event/edit_event.dart';
import '../registration/interests.dart';

class Explore extends StatefulWidget {
  final TabController tabController;
  const Explore({Key? key, required this.tabController}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  TabController? _exploreController;

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _exploreController = widget.tabController;
  }

  void _navigateToEvent(BuildContext context, EventData eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Event(event: eventData),
      ),
    );
  }

  Future<List<EventData>> _performEventsSearch(String searchQuery) async {
    List<EventData> events = [];
    try {
      final eventsSnapshot =
          await _getSnapshot('events', 'event_name', searchQuery);

      setState(() {
        _searchResults.clear();
        for (var event in eventsSnapshot.docs) {
          var eventData = event.data() as Map<String, dynamic>;
          List<Ticket> ticketsList = [];

          if (eventData.containsKey('tickets')) {
            for (var ticket in (eventData['tickets'] as List<dynamic>)) {
              ticketsList.add(Ticket(
                available: ticket['available'],
                title: ticket['ticket_name'],
                price: ticket['price'],
                image: ticket['image'],
                description: ticket['ticket_description'],
                quantity: ticket['quantity'],
              ));
            }
          }

          final EventData foundEvent = EventData(
            eventName: eventData['event_name'],
            location: eventData['location']?['geopoint'],
            category: eventData['category'],
            date: (eventData['date'] as Timestamp?)?.toDate(),
            image: eventData['image'],
            description: eventData['event_description'],
            eventOrganizer: eventData['lister'],
            eventReference: event.reference,
            tickets: ticketsList,
          );

          events.add(foundEvent);
        }
      });

      return events;
    } catch (e) {
      print('Failed to perform events search: $e');
      return events;
    }
  }

  Future<void> _performPeopleSearch(String searchQuery) async {
    await _getSnapshot('account_type', 'username', searchQuery);
    await _getSnapshot('account_type', 'first_name', searchQuery);
    await _getSnapshot('account_type', 'last_name', searchQuery);
  }

  List<dynamic> _searchResults = [];

  Future<void> _performSearch(String searchQuery) async {
    _searchResults.clear();
    var events = await _performEventsSearch(searchQuery);
    setState(() {
      _searchResults.addAll(events);
    });
  }

  Future<QuerySnapshot> _getSnapshot(
      String collection, String field, String searchQuery) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: searchQuery)
        .get();
  }

  Widget _buildSearchBar(BuildContext context, Function(String) searchQuery) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      automaticallyImplyDrawerHamburger: false,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: searchQuery,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _searchResults.map((result) {
                String? resultName() {
                  if (result is EventData) {
                    return result.eventName;
                  }
                  return null;
                }

                String? resultSubtitle() {
                  if (result is EventData) {
                    return null;
                  }
                  return null;
                }

                return GestureDetector(
                  onTap: () {
                    if (result is EventData) {
                      _navigateToEvent(context, result);
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      foregroundImage: NetworkImage(
                        result.image ??
                            'https://i.pinimg.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg',
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    subtitle: Text(resultSubtitle() ?? 'N/A'),
                    title: Text(resultName() ?? 'N/A',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _navigateToUserProfile(
      BuildContext context, String username, DocumentReference reference) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(username)),
          body: FutureBuilder<Patrone>(
              future: Patrone().getPatroneInformation(reference),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No user data found'));
                } else {
                  return ProfileScreen(userProfile: snapshot.data!);
                }
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          children: [
            SizedBox(
              height: height(context),
              width: width(context),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LitTab(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                    icon: const Icon(Icons.event),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditEvent())),
                    label: const Text('Create a new event')),
              ),
            ),
          ],
        ),
        _buildSearchBar(context, _performSearch),
      ],
    );
  }
}

class LitTab extends StatefulWidget {
  const LitTab({Key? key}) : super(key: key);

  @override
  State<LitTab> createState() => _LitTabState();
}

class _LitTabState extends State<LitTab> {
  late Future<List<EventData>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _getAllEvents();
  }

  Future<List<EventData>> _getAllEvents() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      final listedEvents = querySnapshot.docs.map((event) {
        final eventData = event.data();
        final List<Ticket> ticketsList =
            (eventData['tickets'] as List<dynamic>?)
                    ?.map((ticket) => Ticket(
                          available: ticket['available'],
                          title: ticket['ticket_name'],
                          price:
                              double.tryParse(ticket['price'].toString() ?? ''),
                          image: ticket['image'],
                          description: ticket['ticket_description'],
                          quantity: ticket['quantity'],
                        ))
                    .toList() ??
                [];

        return EventData(
          eventName: eventData['event_name'],
          location: eventData['location']?['geopoint'],
          category: eventData['category'],
          date: (eventData['date'] as Timestamp?)?.toDate(),
          image: eventData['image'],
          description: eventData['event_description'],
          eventOrganizer: eventData['lister'],
          eventReference: event.reference,
          tickets: ticketsList,
        );
      }).toList();

      return listedEvents;
    } catch (e) {
      print(e);
      throw Exception('Failed to load events');
    }
  }

  void _navigateToEvent(BuildContext context, EventData eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Event(event: eventData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventData>>(
      future: _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events available'));
        } else {
          final allEvents = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: allEvents.length,
                  itemBuilder: (context, index) {
                    final event = allEvents[index];
                    return ZoomIn(
                      child: GestureDetector(
                        onTap: () => _navigateToEvent(context, event),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(event.image ??
                                    'https://i.pinimg.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg'),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      DateFormat.yMMMd()
                                          .format(event.date ?? DateTime(2000)),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    event.eventName ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Text(
                                    event.category ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
