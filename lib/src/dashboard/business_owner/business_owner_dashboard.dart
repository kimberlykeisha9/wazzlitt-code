import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../place/new_service.dart';

class BusinessOwnerDashboard extends StatefulWidget {
  BusinessOwnerDashboard({super.key, required this.listings});

  List<dynamic> listings;

  @override
  State<BusinessOwnerDashboard> createState() => _BusinessOwnerDashboardState();
}

class _BusinessOwnerDashboardState extends State<BusinessOwnerDashboard> {
  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final List<String> formattedDates =
        weekDays.map((date) => formatter.format(date)).toList();

    return formattedDates;
  }

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
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              DocumentReference data = widget.listings[index];
              return FutureBuilder<DocumentSnapshot>(
                  future: data.get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> listingData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Hero(
                            tag: 'profile',
                            child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    image: listingData['image'] == null
                                        ? null
                                        : DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                listingData['image'])),
                                    color: Colors.grey,
                                    shape: BoxShape.circle)),
                          ),
                          const SizedBox(height: 20),
                          Text(listingData['place_name'] ?? 'null',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          const SizedBox(height: 20),
                          Card(
                              elevation: 10,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(children: [
                                  Text('Daily Stats Overview',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                  SizedBox(height: 20),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text('Services Sold',
                                                style: TextStyle(fontSize: 12)),
                                            Text(
                                                '${(listingData['orders'] != null || listingData.containsKey('orders')) ? (listingData['orders'] as List).length : 0}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 20),
                                            Text('Revenue Earned',
                                                style: TextStyle(fontSize: 12)),
                                            Text('\$0.00',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text('Daily Chats',
                                                style: TextStyle(fontSize: 12)),
                                            Text('0',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 20),
                                            Text('Tagged Posts',
                                                style: TextStyle(fontSize: 12)),
                                            Text('0',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text('Daily Impressions',
                                                style: TextStyle(fontSize: 12)),
                                            Text('0',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 20),
                                            Text('New Followers',
                                                style: TextStyle(fontSize: 12)),
                                            Text('0',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ])
                                ]),
                              )),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text('Services Overview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 10),
                                listingData.containsKey('services') ||
                                        ((listingData['services']
                                                as List<dynamic>?) !=
                                            null)
                                    ? Wrap(
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
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: (listingData['services']
                                                    as List<dynamic>)
                                                .length,
                                            itemBuilder: (context, index) {
                                              Map<String, dynamic> service =
                                                  (listingData['services']
                                                      as List<dynamic>)[index];
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      service['service_name'] ??
                                                          'null',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('Sales'),
                                                        Text('\$' +
                                                            double.parse((service[
                                                                            'price'] *
                                                                        (listingData['orders']
                                                                                as List)
                                                                            .length)
                                                                    .toString())
                                                                .toStringAsFixed(
                                                                    2))
                                                      ]),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('Units Sold'),
                                                        Text((listingData[
                                                                    'orders']
                                                                as List)
                                                            .length
                                                            .toString())
                                                      ]),
                                                  const SizedBox(height: 10),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    : Center(
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
                                            place: data,
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
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Chats received today'),
                                      Text('0')
                                    ]),
                                const SizedBox(height: 5),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Reports received'),
                                      Text('0')
                                    ]),
                                const SizedBox(height: 5),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tagged posts'),
                                      Text('0')
                                    ]),
                                const SizedBox(height: 5),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [Text('Followers'), Text('0')]),
                                const SizedBox(height: 5),
                                const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Profile Visits (Monthly)'),
                                      Text('0')
                                    ]),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  });
            },
          ),
        ),
      ),
    );
  }
}
