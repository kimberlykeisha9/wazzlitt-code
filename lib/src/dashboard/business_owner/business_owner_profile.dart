import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../user_data/user_data.dart';
import '../../app.dart';
import '../../place/edit_place.dart';
import '../../place/service_overview.dart';

class BusinessOwnerProfile extends StatelessWidget {
  BusinessOwnerProfile({super.key, required this.listings});

  List<dynamic> listings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: PageView.builder(itemBuilder: (context, index) {
            DocumentReference placeData = listings[index];
            return FutureBuilder<DocumentSnapshot>(
                future: placeData.get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> listingData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String? openingTime() {
                      if (listingData.containsKey('opening_time')) {
                        Timestamp openingTime = listingData['opening_time'];
                        return DateFormat('hh:mm a')
                            .format(openingTime.toDate());
                      } else {
                        return null;
                      }
                    }

                    String? closingTime() {
                      if (listingData.containsKey('closing_time')) {
                        Timestamp openingTime = listingData['closing_time'];
                        return DateFormat('hh:mm a')
                            .format(openingTime.toDate());
                      } else {
                        return null;
                      }
                    }

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
                                  image: listingData['cover_image'] == null
                                      ? null
                                      : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              listingData['cover_image'])),
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
                                      image: listingData['image'] == null
                                          ? null
                                          : DecorationImage(
                                              image: NetworkImage(
                                                  listingData['image'])),
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
                              Text(listingData['place_name'] ?? 'null',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              const SizedBox(height: 20),
                              const Text('0 Followers'),
                              const SizedBox(height: 10),
                              const Text('97% Popularity'),
                              const SizedBox(height: 10),
                              Text(
                                  listingData['location'] ??
                                      'You have not set your location',
                                  style: TextStyle(fontSize: 14)),
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
                                                EditPlace(place: placeData),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(openingTime() == null
                                        ? 'You have not defined your operating hours'
                                        : 'Open from ${openingTime()} to ${closingTime()}'),
                                    TextButton(
                                      child: const Text('Edit'),
                                      onPressed: () {},
                                    )
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('About Us',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextButton(
                                      child: const Text(''),
                                      onPressed: () {},
                                    )
                                  ]),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  listingData['place_description'] ?? 'null',
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Services',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextButton(
                                      child: const Text(''),
                                      onPressed: () {},
                                    )
                                  ]),
                              listingData.containsKey('services') ||
                                      ((listingData['services']
                                              as List<dynamic>?) !=
                                          null)
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: (listingData['services']
                                              as List<dynamic>)
                                          .length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> service =
                                            (listingData['services']
                                                as List<dynamic>)[index];
                                        return ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ServiceOverview(
                                                        service: service,
                                                        place: placeData),
                                              ),
                                            );
                                          },
                                          trailing: IconButton(
                                            onPressed: () =>
                                                deleteService(service, placeData),
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                image: service['image'] == null
                                                    ? null
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                            service['image']),
                                                        fit: BoxFit.cover)),
                                          ),
                                          title: Text(service['service_name'] ??
                                              'null'),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  '\$${(double.parse(service['price'].toString())).toStringAsFixed(2)}'),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'You have not listed any services',
                                      ),
                                    ),
                              const SizedBox(height: 20),
                              const Text('Tagged Photos',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              TextButton(
                                child: const Text('Tap to review'),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          width: width(context),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            itemBuilder: (context, index) => Container(
                              height: 150,
                              width: width(context) * 0.25,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                });
          }),
        ),
      ),
    );
  }
}
