import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
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
import 'explore/lit_tab.dart';
import 'explore/places_tab.dart';

class Explore extends StatefulWidget {
  final TabController tabController;
  const Explore({Key? key, required this.tabController}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  TabController? _exploreController;


  @override
  void initState() {
    super.initState();
    _exploreController = widget.tabController;
    getPatrone = (val) {
      return val;
    };
  }

  late final Future<Patrone> Function(Future<Patrone>) getPatrone;


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
            paymentURL: ticket['paymentLink']['url'],
            map: ticket,
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

  final List<dynamic> _searchResults = [];

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
                    const LitTab(),
                    PlacesTab(categories: interestCategories),
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
}
