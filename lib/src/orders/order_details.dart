import 'package:flutter/material.dart';
import '../app.dart';

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key, this.orderTitle});

  final String? orderTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.orderTitle ?? ''),
      ),
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: Container(
            color: Colors.grey,
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
                  child: Text(orderTitle ?? 'null',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const Spacer(),
                const Center(child: Text('Order Address')),
                const Spacer(flex: 3),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Order Content', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Quantity',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Order Quantity', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('\$ 0.00', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Validity Date: 01 January 2023',
                    style: TextStyle(fontSize: 14)),
                const Spacer(flex: 3),
                const Text('Payment Status: Completed',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Purchase Date: 01 January 2023',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Order ID: ABCD-EFGH-IJKL-MNOP',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Transaction Type: Credit Card',
                    style: TextStyle(fontSize: 14)),
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
