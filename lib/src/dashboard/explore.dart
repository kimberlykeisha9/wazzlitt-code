import 'package:flutter/material.dart';

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
              LitTab(),
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
    return Column(children: [
      Expanded(
        flex: 2,
        child: SizedBox(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(categories[index].display,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0)),
                      onPressed: () {},
                      child: const Text('See more',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width(context),
                    height: 190,
                    child: ListView.builder(
                      itemCount: 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Place(
                                      placeName: 'Place $i',
                                      category: categories[index].display))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: width(context) / 3,
                                width: width(context) / 3,
                                color: Colors.indigo,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    'Place $i',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // SizedBox(height: ),
                                  const Text(
                                    '0 km away',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 10),
      const Text('Nearby Places',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Flexible(
        child: SizedBox(
          child: ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text('Place $index',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
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
    return Column(
      children: [
        SizedBox(
          height: width(context) * 0.5,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: width(context) * 0.5,
                  width: width(context) * 0.5,
                  color: Colors.indigo,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event $index',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description $index',
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
          ),
        ),
        const Text('Upcoming Events',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: SizedBox(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  onTap: () => {
                    showModalBottomSheet(
                      useSafeArea: true,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.park, size: 80),
                            const SizedBox(height: 10),
                            Text('Event $index',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(
                              'Event $index location',
                            ),
                            const Text('0 km away',
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 10),
                            Text(
                              'Event $index date',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Event $index price',
                            ),
                            const Text('Original price',
                                style: TextStyle(
                                    fontSize: 14,
                                    decoration:
                                        TextDecoration.lineThrough)),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: width(context),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlaceOrder(
                                                orderType:
                                                    OrderType.event,
                                                orderTitle:
                                                    'Event $index'),
                                      ),
                                    );
                                  },
                                  child: const Text('Buy Tickets')),
                            ),
                            const SizedBox(height: 30),
                            Text('About Event $index',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porta, libero at ultricies lacinia, diam sapien lacinia mi, quis aliquet diam ex et massa. Sed a tellus ac tortor placerat rutrum in non nunc. Mauris porttitor dapibus neque, at efficitur erat hendrerit nec. Cras mollis volutpat eros, vestibulum accumsan arcu rutrum a.'),
                            const SizedBox(height: 10),
                            const Chip(label: Text('Category')),
                            const SizedBox(height: 10),
                            const Text('Organizer',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            ListTile(
                              leading: const Icon(Icons.park),
                              title: const Text('Organizer name'),
                              subtitle: const Text('Category'),
                              trailing: TextButton(
                                  onPressed: () {},
                                  child: const Text('Follow')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  },
                  leading: const Icon(Icons.park),
                  title: Text('Event $index',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: const Wrap(
                    direction: Axis.vertical,
                    children: [
                      Text('01/01/1980',
                          style: TextStyle(fontSize: 14)),
                      Text('\$0.00', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
