import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../user_data/user_data.dart';
import 'order_details.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: currentUserPatroneProfile.get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> orders = data['orders'];
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search orders',
                            prefixIcon: Icon(Icons.search),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      ExpansionTile(title: const Text('Valid orders'), children: [
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: orders.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (context, index) {
                            DocumentReference order = orders[index];
                            return FutureBuilder<DocumentSnapshot>(
                              future: order.get(),
                              builder: (context, orderSnapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> orderData = orderSnapshot.data!.data() as Map<String, dynamic>;
                                  DocumentReference? placeData = orderData['place'];
                                  DocumentReference? eventData = orderData['place'];
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: orderData['order_type'] == 'place' ? placeData!.get() : eventData!.get(),
                                    builder: (context, orderTypeSnapshot) {
                                      if(snapshot.hasData) {
                                        Map<String, dynamic> orderTypeData = orderTypeSnapshot.data!.data() as Map<String, dynamic>;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OrderDetails(
                                                  order: orderData,
                                                  orderSourceData: orderTypeData,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(orderTypeData['image']),
                                                    fit: BoxFit.cover,
                                                  )
                                              ),
                                              padding: const EdgeInsets.all(40),
                                              child: Column(
                                                children: [
                                                  const Spacer(flex: 10),
                                                  Text(
                                                    orderData['service']['service_name'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(flex: 3),
                                                  Text(
                                                    '\$ ${double.parse(orderData['service']['price'].toString()).toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    'Purchase Date: ${DateFormat.yMMMd().format((orderData['date_placed'] as Timestamp).toDate())}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const Spacer(flex: 10),
                                                ],
                                              )),
                                        );
                                      } return Center(
                                        child: CircularProgressIndicator()
                                      );
                                    }
                                  );
                                }
                                return Center(child: CircularProgressIndicator());
                              }
                            );
                          },
                        ),
                      ]),
                      ExpansionTile(
                        title: const Text('Past orders'),
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            itemCount: orders.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (context, index) {
                              DocumentReference order = orders[index];
                              return FutureBuilder<DocumentSnapshot>(
                                  future: order.get(),
                                  builder: (context, orderSnapshot) {
                                    if (snapshot.hasData) {
                                      Map<String, dynamic> orderData = orderSnapshot.data!.data() as Map<String, dynamic>;
                                      DocumentReference? placeData = orderData['place'];
                                      DocumentReference? eventData = orderData['place'];
                                      return FutureBuilder<DocumentSnapshot>(
                                          future: orderData['order_type'] == 'place' ? placeData!.get() : eventData!.get(),
                                          builder: (context, orderTypeSnapshot) {
                                            if(snapshot.hasData) {
                                              Map<String, dynamic> orderTypeData = orderTypeSnapshot.data!.data() as Map<String, dynamic>;
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => OrderDetails(
                                                        order: orderData,
                                                        orderSourceData: orderTypeData,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(orderTypeData['image']),
                                                          fit: BoxFit.cover,
                                                          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                                        )
                                                    ),
                                                    padding: const EdgeInsets.all(40),
                                                    child: Column(
                                                      children: [
                                                        const Spacer(flex: 10),
                                                        Text(
                                                          orderData['service']['service_name'],
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const Spacer(flex: 3),
                                                        Text(
                                                          '\$ ${double.parse(orderData['service']['price'].toString()).toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          'Purchase Date: ${DateFormat.yMMMd().format((orderData['date_placed'] as Timestamp).toDate())}',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const Spacer(flex: 10),
                                                      ],
                                                    )),
                                              );
                                            } return Center(
                                                child: CircularProgressIndicator()
                                            );
                                          }
                                      );
                                    }
                                    return Center(child: CircularProgressIndicator());
                                  }
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }
        ));
  }
}
