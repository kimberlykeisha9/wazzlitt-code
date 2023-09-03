import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/event/event.dart';

import '../../user_data/user_data.dart';
import '../app.dart';
import '../place/place.dart';
import '../registration/interests.dart';

class Explore extends StatefulWidget {
  final TabController tabController;
  const Explore({super.key, required this.tabController});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  TabController? _exploreController;
  String _selectedChip = '';

  List<Category> categories = [];

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
        String readableLocation = '${placemark.street}, ${placemark.country}';

        return readableLocation;
      }
    } catch (e) {
      log('Error: $e');
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    _exploreController = widget.tabController;
    firestore.collection('app_data').doc('categories').get().then((value) {
      var data = value.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        var itemData = value as Map<String, dynamic>;
        String display = itemData['display'];
        String image = itemData['image'];
        setState(() {
          Category category = Category(display, image);
          categories.add(category);
        });
      });
    });
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
                  const LitTab(),
                  PlacesTab(categories: categories),
                ],
              ),
            ),
          ],
        ),
        searchBar(context),
      ],
    );
  }

  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  Future<void> _performSearch(String searchQuery) async {
    // Searches Users
    final QuerySnapshot usernamesSnapshot = await firestore
        .collectionGroup('account_type')
        .where('username', isEqualTo: searchQuery)
        .get();
    final QuerySnapshot firstNamesSnapshot = await firestore
        .collectionGroup('account_type')
        .where('first_name', isEqualTo: searchQuery)
        .get();
    final QuerySnapshot lastNamesSnapshot = await firestore
        .collectionGroup('account_type')
        .where('last_name', isEqualTo: searchQuery)
        .get();

    // Searches events
    final QuerySnapshot eventsSnapshot = await firestore
        .collection('events')
        .where('event_name', isEqualTo: searchQuery)
        .get();

    // Searches places
    final QuerySnapshot placesSnapshot = await firestore
        .collection('places')
        .where('place_name', isEqualTo: searchQuery)
        .get();

    setState(() {
      _searchResults = usernamesSnapshot.docs +
          firstNamesSnapshot.docs +
          lastNamesSnapshot.docs +
          eventsSnapshot.docs +
          placesSnapshot.docs;
    });
  }

  Widget searchBar(BuildContext context) {
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
      onQueryChanged: (query) {
        _performSearch(query);
      },
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
              children: _searchResults.map((document) {
                Map<String, dynamic> documentData =
                    document.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    if (document.reference.path.startsWith('users')) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  appBar:
                                      AppBar(title: Text(document['username'])),
                                  body: ProfileScreen(
                                      userProfile: document.reference))));
                    } else if (document.reference.path.startsWith('places')) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Place(
                                  place: document.data()
                                      as Map<String, dynamic>)));
                    } else if (document.reference.path.startsWith('events')) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Event(
                                  event: document.data()
                                      as Map<String, dynamic>)));
                    }
                    ;
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      foregroundImage: NetworkImage(
                        documentData['image'] ??
                            documentData['profile_picture'] ??
                            'https://i.pinimg'
                                '.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg',
                      ),
                    ),
                    title: Text(documentData['event_name'] ??
                        documentData['place_name'] ??
                        documentData['username'] ??
                        ''),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class PlacesTab extends StatelessWidget {
  const PlacesTab({
    super.key,
    required this.categories,
  });

  final List<Category> categories;

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
          child: FutureBuilder<QuerySnapshot>(
              future: firestore.collection('places').get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> placesList = snapshot.data!.docs;
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      print(placesList);
                      Map<String, dynamic> place =
                          placesList[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => Place(place: place))),
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(place['image'] ??
                                'https://i.pinimg.com/564x/90/0b/c3/900bc32b424bc3b817ff1edd38476991.jpg'),
                          )),
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
                                    place['category'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                place['place_name'],
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
                return const Center(child: CircularProgressIndicator());
              }),
        ),
      ],
    );
  }
}

class LitTab extends StatelessWidget {
  const LitTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: firestore.collection('events').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docList = snapshot.data!.docs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: docList.length,
                      itemBuilder: (context, index) {
                        print(docList);
                        Map<String, dynamic> result =
                            docList[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Event(event: result))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(result['image']),
                              )),
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
                                            (result['date'] ?? Timestamp.now())
                                                .toDate()),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      result['event_name'],
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
                                      result['category'],
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
        });
  }
}
