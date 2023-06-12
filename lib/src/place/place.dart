import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../app.dart';
import 'place_order.dart';

class Place extends StatelessWidget {
  const Place({super.key, this.placeName, this.category});

  final String? placeName;
  final String? category;

  void _shareOnFacebook() {
    Share.share('Shared on Facebook');
  }

  void _shareOnTwitter() {
    Share.share('Shared on Twitter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeName ?? 'Null'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share on social media'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.facebook),
                        title: const Text('Share on Facebook'),
                        onTap: () {
                          // Implement Facebook sharing logic here
                          _shareOnFacebook();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.twitter),
                        title: const Text('Share on Twitter'),
                        onTap: () {
                          // Implement Twitter sharing logic here
                          _shareOnTwitter();
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                      // Add more social media sharing options as needed
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Container(
                      width: width(context),
                      height: 150,
                      color: Colors.grey,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
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
                    Text(placeName ?? 'Null',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    Chip(label: Text(category ?? 'Null')),
                    const Text('Open - 08:00 AM to 08:00 PM'),
                    const SizedBox(height: 5),
                    const Text('Popularity: 95%',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5)),
                              onPressed: () {},
                              child: const Text('Follow',
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
                              child: const Text('Chat Room',
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
                              child: const Text('Contact',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text('About ${placeName ?? 'Null'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    const SizedBox(height: 10),
                    const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing '
                        'elit. Praesent porta, libero at ultricies '
                        'lacinia, diam sapien lacinia mi, quis aliquet '
                        'diam ex et massa. Sed a tellus ac tortor '
                        'placerat rutrum in non nunc.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceOrder(
                                orderType: OrderType.service,
                                orderTitle: placeName ?? ''),
                          ),
                        );
                      },
                      child: const Text('Check out our services'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Street Name', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: width(context),
                height: 100,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Photos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                        height: 20,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {},
                            child: const Text('See more',
                                style: TextStyle(fontSize: 12)))),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                width: width(context),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        width: width(context) * 0.25,
                        color: Colors.grey,
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

