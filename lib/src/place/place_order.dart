import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key, required this.orderType, required this
      .orderTitle, this.event, this.place});

  final OrderType orderType;
  final String orderTitle;
  final Map<String, dynamic>? event;
  final Map<String, dynamic>? place;

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  List<dynamic>? tickets = [];
  List<dynamic>? services = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tickets = widget.event?['tickets'] ?? [];
    services = widget.place?['services'] ?? [];
  }
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
          widget.orderType == OrderType.event ? ListView.builder(
            shrinkWrap: true,
            itemCount: tickets?.length ?? 0,
            itemBuilder: (context, index) {
              Selector ticket = Selector(item: tickets![index]);
              // var ticket = tickets![index];
              return SizedBox(
                width: width(context),
                child: ListTile(
                        title: Text(ticket.item!['name']),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket.item!.containsKey('price') ? '\$'
                '${double.parse(ticket.item!['price'].toString())
                                .toStringAsFixed
                  (2)}'
                    : 'Free'),
                            // Text(ticket.containsKey('description') ?
                            // ticket['description'] : ''),
                          ],
                        ),
                        leading:
                        ticket.item!.containsKey('description') ? Tooltip
                          (message: ticket.item!['description'], child: const
                        Icon
                          (Icons.info_outline)) :
                        const SizedBox(),
                        trailing: ticket.item!['quantity'] > 0 ? Row(
                          mainAxisSize: MainAxisSize.min,                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  ticket.quantity = ticket.quantity - 1;
                                });
                              },
                            ),
                            Text(
                              ticket.quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  ticket.quantity = ticket.quantity + 1;
                                });
                              },
                            ),
                          ],
                        ) : const Text('Sold Out')),
              );
            },
          ) : ListView.builder(
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (context, index) {
              int quantity = 0;
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
                        onPressed: () {},
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
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
                        onPressed: () {},
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
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
 class Selector extends ChangeNotifier {
  int quantity = 0;
  final Map<String, dynamic>? item;

  Selector({this.item});

  increment() {
    quantity + 1;
    notifyListeners();
  }

  decrement() {
    quantity - 1;
    notifyListeners();
  }
 }