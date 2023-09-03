import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../user_data/business_owner_data.dart';
import '../../app.dart';
import '../../place/new_service.dart';

class BusinessOwnerDashboard extends StatefulWidget {
  const BusinessOwnerDashboard({super.key});

  @override
  State<BusinessOwnerDashboard> createState() => _BusinessOwnerDashboardState();
}

class _BusinessOwnerDashboardState extends State<BusinessOwnerDashboard> {
  DateTime period = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        period = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: FutureBuilder<List<BusinessPlace>>(
              future: BusinessOwner().getListedBusiness(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loading indicator while waiting for the data.
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle error here.
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Handle case when there are no businesses available.
                  return Center(child: Text('No businesses available.'));
                } else {
                  final listings = snapshot.data!;
                  return PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      final services = listing.services ?? [];

                      return Column(
                        children: [
                          Hero(
                            tag: 'profile',
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                image: listing.image == null
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(listing.image!)),
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(listing.placeName ?? 'null',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text('Daily Stats Overview',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Add your daily stats widgets here
                                      Column(
                                        children: [
                                          const Text('Services Sold',
                                              style: TextStyle(fontSize: 12)),
                                          Text('${listing.orders?.length ?? 0}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 20),
                                          const Text('Revenue Earned',
                                              style: TextStyle(fontSize: 12)),
                                          const Text('\$0.00',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('Daily Chats',
                                              style: TextStyle(fontSize: 12)),
                                          Text('0',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 20),
                                          Text('Tagged Posts',
                                              style: TextStyle(fontSize: 12)),
                                          Text('0',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('Daily Impressions',
                                              style: TextStyle(fontSize: 12)),
                                          Text('0',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 20),
                                          Text('New Followers',
                                              style: TextStyle(fontSize: 12)),
                                          Text('0',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Services Overview
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text('Services Overview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 10),
                                services.isNotEmpty
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'Week (${getCurrentWeek()[0]} - ${getCurrentWeek()[6]})'),
                                              TextButton(
                                                onPressed: () =>
                                                    _selectDate(context),
                                                child:
                                                    const Text('Change Period'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // Service list
                                          // Use ListView.builder for the list of services
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: services.length,
                                            itemBuilder: (context, index) {
                                              final service = services[index];
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(service.title ?? 'null',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('Sales'),
                                                      Text(
                                                        '\$${(service.price! * listing.orders!.length).toStringAsFixed(2)}',
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('Units Sold'),
                                                      Text(
                                                        listing.orders!.length
                                                            .toString(),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Text(
                                            'You have not listed any services')),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: width(context),
                                  child: ElevatedButton(
                                    child: const Text('Add a new service'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewService(
                                            place: listing.placeReference!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Performance Overview',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                // Your performance overview widgets here
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              }),
        ),
      ),
    );
  }

  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final List<String> formattedDates =
        weekDays.map((date) => formatter.format(date)).toList();

    return formattedDates;
  }
}
