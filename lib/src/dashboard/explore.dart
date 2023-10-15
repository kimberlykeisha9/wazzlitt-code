import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:wazzlitt/src/dashboard/patrone_dashboard.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/event/event.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import '../place/place.dart';
import '../registration/interests.dart';

class Explore extends StatefulWidget {
  final TabController tabController;
  const Explore({Key? key, required this.tabController}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  TabController? _exploreController;
  String _selectedChip = '';

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _exploreController = widget.tabController;
    _loadCategories();
    getPatrone = (val) {
      return val;
    };
  }

  late final Future<Patrone> Function(Future<Patrone>) getPatrone;

  Future<void> _loadCategories() async {
    final value =
        await firestore.collection('app_data').doc('categories').get();
    final data = value.data() as Map<String, dynamic>;

    categories = data.entries.map((entry) {
      final itemData = entry.value as Map<String, dynamic>;
      return Category(entry.key, itemData['image']);
    }).toList();
  }

  void _navigateToPlace(BuildContext context, BusinessPlace placeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Place(place: placeData),
      ),
    );
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
    List<EventData> results = [];
    final eventsSnapshot =
        await _getSnapshot('events', 'event_name', searchQuery);

    for (var event in eventsSnapshot.docs) {
      var eventData = event.data() as Map<String, dynamic>?;
      List<Ticket>? ticketsList = [];

      if (eventData!.containsKey('tickets')) {
        for (Map<String, dynamic> ticket
            in (eventData['tickets'] as List<dynamic>)) {
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

      results.add(foundEvent);
    }
    return results;
  }

  Future<List<Patrone>> _performPeopleSearch(String searchQuery) async {
    List<Patrone> pResults = [];
    final usernamesSnapshot =
        await _getSnapshotForGroup('account_type', 'username', searchQuery);
    final firstNamesSnapshot =
        await _getSnapshotForGroup('account_type', 'first_name', searchQuery);
    final lastNamesSnapshot =
        await _getSnapshotForGroup('account_type', 'last_name', searchQuery);

    var results = usernamesSnapshot.docs +
        firstNamesSnapshot.docs +
        lastNamesSnapshot.docs;

    for (var result in results) {
      await Patrone().getPatroneInformation(result.reference).then((value) {
        Patrone foundPatrone = value;

        pResults.add(foundPatrone);
      });
    }
    return pResults;
  }

  Future<List<BusinessPlace>> _performPlacesSearch(String searchQuery) async {
    List<BusinessPlace> results = [];
    final placesSnapshot =
        await _getSnapshot('places', 'place_name', searchQuery);

    for (var place in placesSnapshot.docs) {
      var placeData = place.data() as Map<String, dynamic>?;
      List<Service>? servicesList = [];

      if (placeData!.containsKey('services')) {
        for (Map<String, dynamic> service
            in (placeData['services'] as List<dynamic>)) {
          servicesList.add(Service(
            available: service['available'],
            title: service['service_name'],
            price: service['price'],
            image: service['image'],
            description: service['service_description'],
            quantity: service['quantity'],
          ));
        }
      }

      final BusinessPlace foundBusinessPlace = BusinessPlace(
        placeName: placeData['place_name'],
        location: placeData['location']['geopoint'],
        category: placeData['category'],
        placeType: placeData['place_type'],
        closingTime: (placeData['closing_time'] as Timestamp?)?.toDate(),
        openingTime: (placeData['opening_time'] as Timestamp?)?.toDate(),
        emailAddress: placeData['email_address'],
        image: placeData['image'],
        coverImage: placeData['cover_image'],
        description: placeData['place_description'],
        lister: placeData['lister'],
        placeReference: place.reference,
        chatroom: placeData['chat_room'],
        phoneNumber: placeData['phone_number'],
        website: placeData['website'],
        services: servicesList,
      );

      results.add(foundBusinessPlace);
    }

    return results;
  }

  List<dynamic> _searchResults = [];

  Future<void> _performSearch(String searchQuery) async {
    _searchResults.clear();
    var places = await _performPlacesSearch(searchQuery);
    var events = await _performEventsSearch(searchQuery);
    var people = await _performPeopleSearch(searchQuery);
    var googleSearch = await searchBuildings(searchQuery);
    _searchResults.addAll(people);
    _searchResults.addAll(events);
    _searchResults.addAll(places);
    _searchResults.addAll(googleSearch);
  }

  Future<QuerySnapshot> _getSnapshotForGroup(
      String collection, String field, String searchQuery) async {
    var request = await firestore
        .collectionGroup(collection)
        .where(field, isEqualTo: searchQuery)
        .get();
    return request;
  }

  Future<QuerySnapshot> _getSnapshot(
      String collection, String field, String searchQuery) async {
    var request = await firestore
        .collection(collection)
        .where(field, isEqualTo: searchQuery)
        .get();
    return request;
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
                  if (result is BusinessPlace) {
                    return result.placeName;
                  } else if (result is EventData) {
                    return result.eventName;
                  } else if (result is Patrone) {
                    return '${result.firstNameSet} ${result.lastNameSet}';
                  }
                  return null;
                }

                String? resultImage() {
                  if (result is BusinessPlace) {
                    return result.image;
                  } else if (result is EventData) {
                    return result.image;
                  } else if (result is Patrone) {
                    return result.profilePictureSet;
                  }
                  return null;
                }

                String? resultSubtitle() {
                  if (result is BusinessPlace) {
                    return result.formattedAddress;
                  } else if (result is EventData) {
                    return null;
                  } else if (result is Patrone) {
                    return result.usernameSet;
                  }
                  return null;
                }

                return GestureDetector(
                  onTap: () {
                    if (result is BusinessPlace) {
                      _navigateToPlace(context, result);
                    } else if (result is EventData) {
                      _navigateToEvent(context, result);
                    } else if (result is Patrone) {
                      _navigateToUserProfile(
                          context, result.usernameSet!, result);
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      foregroundImage: NetworkImage(
                        resultImage() ??
                            'https://corsproxy.io/?https://i.pinimg.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg',
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
      BuildContext context, String username, Patrone patrone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(username)),
          body: ProfileScreen(userProfile: patrone),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: height(context),
          width: width(context),
          decoration: const BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories
                      .map(
                        (chip) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(chip.display),
                            selected: _selectedChip == chip.display,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChip = selected ? chip.display : '';
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ), */
              Expanded(
                child: TabBarView(
                  controller: _exploreController,
                  children: [
                    LitTab(),
                    PlacesTab(categories: categories),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildSearchBar(context, _performSearch),
      ],
    );
  }

  final TextEditingController _searchController = TextEditingController();
}

class PlacesTab extends StatefulWidget {
  PlacesTab({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<Category> categories;

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToPlace(BuildContext context, BusinessPlace placeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Place(place: placeData),
      ),
    );
  }

  List<BusinessPlace> allPlaces = [];

  late Future<List<BusinessPlace>> getPlaceFuture = getAllPlaces();

  Future<List<BusinessPlace>> getPlacesFromGoogle =
      searchBuildings('Places near me');

  Future<List<BusinessPlace>> getAllPlaces() async {
    try {
      List<BusinessPlace> _places = [];
      await firestore.collection('places').get().then((places) {
        for (var place in places.docs) {
          var placeData = place.data() as Map<String, dynamic>?;
          List<Service>? servicesList = [];

          if (placeData!.containsKey('services')) {
            for (Map<String, dynamic> service
                in (placeData['services'] as List<dynamic>)) {
              servicesList.add(Service(
                available: service['available'],
                title: service['service_name'],
                price: service['price'],
                image: service['image'],
                description: service['service_description'],
                quantity: service['quantity'],
              ));
            }
          }

          final BusinessPlace foundBusinessPlace = BusinessPlace(
            placeName: placeData['place_name'],
            location: placeData['location']['geopoint'],
            category: placeData['category'],
            placeType: placeData['place_type'],
            closingTime: (placeData['closing_time'] as Timestamp?)?.toDate(),
            openingTime: (placeData['opening_time'] as Timestamp?)?.toDate(),
            emailAddress: placeData['email_address'],
            image: placeData['image'],
            coverImage: placeData['cover_image'],
            description: placeData['place_description'],
            lister: placeData['lister'],
            placeReference: place.reference,
            chatroom: placeData['chat_room'],
            phoneNumber: placeData['phone_number'],
            website: placeData['website'],
            services: servicesList,
          );

          if (_places.contains(foundBusinessPlace)) {
            _places
                .where((place) =>
                    place.placeReference == foundBusinessPlace.placeReference)
                .toList()
                .forEach((removablePlace) {
              _places.remove(removablePlace);
            });
          } else {
            _places.add(foundBusinessPlace);
          }
        }
      });

      return _places;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Featured Places',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<BusinessPlace>>(
            future: getPlacesFromGoogle,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!(snapshot.hasData) ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No places are currently available'));
              } else {
                allPlaces = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: allPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    final place = allPlaces[index];

                    return GestureDetector(
                      onTap: () => _navigateToPlace(context, place),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              place.image ??
                                  'https://corsproxy.io/?https://i.pinimg.com/564x/90/0b/c3/900bc32b424bc3b817ff1edd38476991.jpg',
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  place.category ?? 'Not available',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              place.placeName ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class LitTab extends StatefulWidget {
  LitTab({
    Key? key,
  }) : super(key: key);

  @override
  State<LitTab> createState() => _LitTabState();
}

class _LitTabState extends State<LitTab> {
  List<EventData> allEvents = [];

  Future<List<EventData>> getAllEvents() async {
    try {
      List<EventData> listedEvents = [];
      await firestore
          .collection('events')
          .where('date', isGreaterThan: DateTime.now())
          .get()
          .then((events) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> event in events.docs) {
          var eventData = event.data();
          List<Ticket>? ticketsList = [];

          if (eventData.containsKey('tickets') && eventData['tickets'] != []) {
            for (Map<String, dynamic> ticket
                in (eventData['tickets'] as List<dynamic>)) {
              ticketsList.add(Ticket(
                available: ticket['available'],
                title: ticket['ticket_name'],
                price: double.tryParse(ticket['price'].toString() ?? ''),
                image: ticket['image'],
                description: ticket['ticket_description'],
                quantity: ticket['quantity'],
              ));
            }
          }

          listedEvents.add(EventData(
            eventName: eventData['event_name'],
            location: eventData['location']?['geopoint'],
            category: eventData['category'],
            date: (eventData['date'] as Timestamp?)?.toDate(),
            image: eventData['image'],
            description: eventData['event_description'],
            eventOrganizer: eventData['lister'],
            eventReference: event.reference,
            tickets: ticketsList,
          ));
        }
      });
      return listedEvents;
    } on Exception catch (e) {
      throw Exception(e);
    }
    // catch (e) {
    //   print("Error fetching events: $e");
    //   throw Exception(e);
    // }
  }

  void _navigateToEvent(BuildContext context, EventData eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Event(event: eventData),
      ),
    );
  }

  late final Future<List<EventData>> getEvents = getAllEvents();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventData>>(
      future: getEvents,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events are currently available'));
        } else {
          allEvents = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Featured Events',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SizedBox(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
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
                                  image: NetworkImage(event.image!),
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
                                        DateFormat.yMMMd().format(
                                            (event.date ?? DateTime(2000))),
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      event.eventName ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
              ),
            ],
          );
        }
      },
    );
  }
}
