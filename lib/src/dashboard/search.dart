import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/src/event/event.dart';
import 'package:wazzlitt/src/place/place.dart';
import 'package:wazzlitt/user_data/user_data.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

  // Creates List of the results
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                print(_searchResults!.length);
                _performSearch(value);
              },
            ),
            SizedBox(height: 16),
            _searchResults != null
                ? Expanded(
                    child: GridView.builder(
                      itemCount: _searchResults!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        final document = _searchResults![index];
                        Map<String, dynamic> documentData = document.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            if (document.reference.path.startsWith('users')) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(appBar:
                                  AppBar(title: Text(document['username'])),
                                  body: ProfileScreen(userProfile: document.reference))));
                            } else if (document.reference.path.startsWith('places')) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Place(place: document.data() as Map<String, dynamic>)));
                            } else if (document.reference.path.startsWith('events')) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Event(event: document.data() as Map<String, dynamic>)));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(documentData['image'] ?? documentData['profile_picture'] ?? 'https://i.pinimg.com/736x/58/58/c9/5858c9e33da2df781d11a0993f9b7030.jpg',),
                              ),
                            ),
                            child: Center(child: Text(documentData['event_name'] ?? documentData['place_name'] ?? documentData['username'] ?? '')),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
