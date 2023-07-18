import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/src/event/event.dart';

import '../../user_data/user_data.dart';
import '../app.dart';
import '../place/place.dart';
import '../place/place_order.dart';
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
    return Column(
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
      FutureBuilder<QuerySnapshot>(
          future: firestore.collection('places').get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot> placesList = snapshot.data!.docs;
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
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
                            image: NetworkImage(place['image']),
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
                              child: Text(place['category'], style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),),
                            ),
                          ),
                          Spacer(),
                          Text(
                            place['place_name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '0 km away',
                            style: const TextStyle(
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
            return Center(child: CircularProgressIndicator());
          }),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Nearby Places',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 2,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.place),
              title: Text('Place $index',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Wrap(
                direction: Axis.vertical,
                children: [
                  Text('Location', style: TextStyle(fontSize: 14)),
                  Text('0 km away', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
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
                SizedBox(
                  height: width(context) * 0.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: width(context) * 0.5,
                            width: width(context) * 0.5,
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
                                Text(
                                  result['event_name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result['category'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text('Upcoming Events',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: docList.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> event =
                            docList[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            visualDensity: VisualDensity.standard,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Event(event: event))),
                            leading: SizedBox(
                              width: 80,
                              height: 80,
                              child: Hero(
                                tag: event['event_name'],
                                child: Image.network(
                                  event['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(event['event_name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: Text(
                                (event.containsKey('price'))
                                    ? '\$'
                                        '${double.parse(event['price'].toString()).toStringAsFixed(2)}'
                                    : 'Free',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            subtitle: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text(
                                    (event.containsKey('date'))
                                        ? DateFormat.yMEd().format(
                                            (event['date'] as Timestamp)
                                                .toDate())
                                        : 'Date TBA',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 2),
                                Text(
                                    (event.containsKey('location'))
                                        ? event['location']
                                        : 'Location TBA',
                                    style: TextStyle(fontSize: 14)),
                              ],
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
          return Center(child: CircularProgressIndicator());
        });
  }
}
