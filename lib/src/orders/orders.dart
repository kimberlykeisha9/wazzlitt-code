import 'package:cloud_firestore/cloud_firestore.dart' as db;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../user_data/order_data.dart';
import '../app.dart';
import 'order_details.dart';
import '../../user_data/patrone_data.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Patrone>(context, listen: false).getCurrentUserOrders();
    orderFuture = (val) {
      return val;
    };
  }

  late final Future<db.DocumentSnapshot> Function(
      Future<db.DocumentSnapshot<Object?>>) orderFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: Container(
          height: height(context),
          width: width(context),
          decoration: BoxDecoration(),
          child: FutureBuilder(
              future: null,
              builder: (context, snapshot) {
                List<Order> orders =
                    Provider.of<Patrone>(context).placedOrders ?? [];
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(children: [
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
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: orders.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          Order order = orders[index];
                          return FutureBuilder(
                              future: null,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  db.DocumentReference? orderReference =
                                      order.reference;
                                  return FutureBuilder<db.DocumentSnapshot>(
                                      future:
                                          orderFuture(orderReference!.get()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          Map<String, dynamic> orderTypeData =
                                              snapshot.data!.data()
                                                  as Map<String, dynamic>;
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetails(
                                                    order: order,
                                                    orderSourceData:
                                                        orderTypeData,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  image: NetworkImage(
                                                      orderTypeData['image']),
                                                  fit: BoxFit.cover,
                                                )),
                                                padding:
                                                    const EdgeInsets.all(40),
                                                child: Column(
                                                  children: [
                                                    const Spacer(flex: 10),
                                                    Text(
                                                      (order.orderType ==
                                                              OrderType.service)
                                                          ? order.details![
                                                              'service_name']
                                                          : order.details![
                                                              'ticket_name'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Spacer(flex: 3),
                                                    Text(
                                                      '\$ ${double.parse(order.details!['price'].toString()).toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      'Purchase Date: ${DateFormat.yMMMd().format(order.datePlaced!)}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const Spacer(flex: 10),
                                                  ],
                                                )),
                                          );
                                        }
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      });
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              });
                        },
                      ),
                    ]),
                  ),
                );
              }),
        ));
  }
}
