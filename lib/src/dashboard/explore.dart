import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/event/event.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
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
  }

  Future<void> _loadCategories() async {
    final value =
        await firestore.collection('app_data').doc('categories').get();
    final data = value.data() as Map<String, dynamic>;

    setState(() {
      categories = data.entries.map((entry) {
        final itemData = entry.value as Map<String, dynamic>;
        return Category(entry.key, itemData['image']);
      }).toList();
    });
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

  Future<void> _performEventsSearch(String searchQuery) async {
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

      if (_searchResults.contains(foundEvent)) {
        _searchResults
            .where((event) => event.eventReference == foundEvent.eventReference)
            .toList()
            .forEach((element) {
          setState(() {
            _searchResults.remove(element);
          });
        });
      } else {
        setState(() {
          _searchResults.add(foundEvent);
        });
      }
    }

    setState(() {
      _searchResults = [
        ...eventsSnapshot.docs,
      ];
    });
  }

  Future<void> _performPeopleSearch(String searchQuery) async {
    final usernamesSnapshot =
        await _getSnapshot('account_type', 'username', searchQuery);
    final firstNamesSnapshot =
        await _getSnapshot('account_type', 'first_name', searchQuery);
    final lastNamesSnapshot =
        await _getSnapshot('account_type', 'last_name', searchQuery);
  }

  Future<void> _performPlacesSearch(String searchQuery) async {
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

      if (_searchResults.contains(foundBusinessPlace)) {
        _searchResults
            .where((place) =>
                place.placeReference == foundBusinessPlace.placeReference)
            .toList()
            .forEach((removablePlace) {
          setState(() {
            _searchResults.remove(removablePlace);
          });
        });
        print('Removed listing. New value is ${_searchResults.length}');
      } else {
        setState(() {
          _searchResults.add(foundBusinessPlace);
        });
        print('Added listing. New value is ${_searchResults.length}');
      }
    }
  }

  List<dynamic> _searchResults = [];

  Future<void> _performSearch(String searchQuery) async {
    await _performPlacesSearch(searchQuery);
    await _performEventsSearch(searchQuery);
    var googleSearch = await searchBuildings(searchQuery);
    _searchResults.addAll(googleSearch);
  }

  Future<QuerySnapshot> _getSnapshot(
      String collection, String field, String searchQuery) async {
    return await firestore
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
          if(result is BusinessPlace) {
            return result.placeName;
          } else if (result is EventData) {
            return result.eventName;
          } return null;
        };
                return GestureDetector(
                  onTap: () {
                    if (result is BusinessPlace) {
                      _navigateToPlace(
                          context, result);
                    } else if (result is EventData) {
                      // _navigateToEvent(
                      //     context, document.data() as Map<String, dynamic>);
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
                    title: Text(resultName() ?? 'N/A', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
          body: ProfileScreen(userProfile: reference),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
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
            ),
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
        _buildSearchBar(context, _performSearch),
      ],
    );
  }

  final TextEditingController _searchController = TextEditingController();
}

class PlacesTab extends StatelessWidget {
  PlacesTab({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<Category> categories;

  void _navigateToPlace(BuildContext context, BusinessPlace placeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Place(place: placeData),
      ),
    );
  }

  List<BusinessPlace> allPlaces = [];

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
      print('Removed listing. New value is ${_places.length}');
    } else {
        _places.add(foundBusinessPlace);
      print('Added listing. New value is ${_places.length}');
    }
  }
  });
  
  return _places;
} on Exception catch (e) {
  print(e);
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
            future: getAllPlaces(),
            builder: (context, snapshot) {
              if (!(snapshot.hasData) || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No places found'));
              }
              else {
                allPlaces = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: allPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    final place =
                        allPlaces[index];
                        
                    return GestureDetector(
                      onTap: () => _navigateToPlace(context, place),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              place.image ??
                                  'https://i.pinimg.com/564x/90/0b/c3/900bc32b424bc3b817ff1edd38476991.jpg',
                            ),
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
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  place.category ?? 'Not available',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              place.placeName ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '0 km away',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
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

class LitTab extends StatelessWidget {
  LitTab({
    Key? key,
  }) : super(key: key);

  List<EventData> allEvents = [];

  Future<List<EventData>> getAllEvents() async {
    try {
  List<EventData> _events = [];
  await firestore.collection('events').get().then((events) {
    for (var event in events.docs) {
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
  
    if (_events.contains(foundEvent)) {
            _events
                .where((event) =>
                    event.eventReference == foundEvent.eventReference)
                .toList()
                .forEach((element) {
              _events.remove(element);
            });
          } else {
            _events.add(foundEvent);
          }
        }
  });
  
  return _events;
} on Exception catch (e) {
  print(e);
  throw Exception(e);
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
      future: getAllEvents(),
      builder: (context, snapshot) {
              if (!(snapshot.hasData) || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No events found'));
              }
              else {
                allEvents = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: allEvents.length,
                    itemBuilder: (context, index) {
                      final event =
                          allEvents[index];
                      return GestureDetector(
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
                                          (event.date!)),
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
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

