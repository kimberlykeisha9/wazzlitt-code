import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app.dart';

class OrderDetails extends StatelessWidget {
  OrderDetails({super.key, required this.order, required this.orderSourceData});

  Map<String, dynamic> orderSourceData;
  Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order['service']?['service_name'] ?? order['ticket']?['ticket_name'] ?? ''),
      ),
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(orderSourceData['image']),fit: BoxFit.cover
              )
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(order['order_type'] == 'place' ? order['service']['service_name'] : order['ticket']['ticket_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const Spacer(),
                Center(child: Text(orderSourceData['location'] ?? 'Not mentioned')),
                const Spacer(flex: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(order['order_type'] == 'place' ? order['service']['service_name'] : order['ticket']['ticket_name'], style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text('Quantity',
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.bold)),
                    //     SizedBox(height: 10),
                    //     Text('1', style: TextStyle(fontSize: 14)),
                    //   ],
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('\$ ${double.parse((order['order_type'] == 'place' ? order['service'] : order['ticket'])['price'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                const Text('Payment Status: Completed',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                Text('Purchase Date: ${DateFormat.yMMMd().format((order['date_placed'] as Timestamp).toDate())}',
                    style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Text('Order ID: ${(order['order_id'] as String).toUpperCase()}',
                    style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Text('Payment Type: ${(order['payment_type'] as String).toUpperCase()}',
                    style: const TextStyle(fontSize: 14)),
                const Spacer(flex: 3),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Request Invoice')),
                ),
                const Spacer(),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Raise Dispute')),
                ),
                const Spacer(),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Contact Organizer')),
                ),
              ],
            ),
          ),
        )
      ])),
    );
  }
}
