import 'package:flutter/material.dart';
import '../app.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key, required this.orderType, required this.orderTitle});

  final OrderType orderType;
  final String orderTitle;

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderType == OrderType.service
            ? 'Services for ${widget.orderTitle}'
            : 'Tickets for ${widget.orderTitle}'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(widget.orderTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(widget.orderType == OrderType.service
              ? 'Choose which services you would like to order'
              : 'Choose which tickets you would like to order'),
          const Spacer(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              int quantity = 1;

              void increment() {
                setState(() {
                  quantity++;
                });
              }

              void decrement() {
                if (quantity > 1) {
                  setState(() {
                    quantity--;
                  });
                }
              }

              return widget.orderType == OrderType.service
                  ? ListTile(
                      title: Text('Service $index'),
                      subtitle: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$ 0.00'),
                          Text('Service description'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: decrement,
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: increment,
                          ),
                        ],
                      ))
                  : ListTile(
                      title: Text('Ticket Type $index'),
                      subtitle: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$ 0.00'),
                          Text('Ticket type description'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: decrement,
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: increment,
                          ),
                        ],
                      ));
            },
          ),
          const Spacer(flex: 3),
          CheckboxListTile(
              value: true,
              onChanged: (val) {},
              subtitle: const Text('I confirm that I am liable to the Terms and '
                  'Conditions of this purchase and all other regulations set.')),
          const Spacer(flex: 3),
          SizedBox(
              width: width(context),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, 'confirmed');
                  },
                  child: const Text('Checkout'))),
          const Spacer(flex: 5),
        ]),
      )),
    );
  }
}
