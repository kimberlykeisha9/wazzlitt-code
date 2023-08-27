import 'package:flutter/material.dart';
import 'package:wazzlitt/user_data/payments.dart';
import '../../user_data/user_data.dart';
import '../app.dart';

class EventOrder extends StatefulWidget {
  const EventOrder({super.key, required this.event});

  final Map<String, dynamic> event;

  @override
  State<EventOrder> createState() => _EventOrderState();
}

class _EventOrderState extends State<EventOrder> {
  List<dynamic>? tickets = [];
  int? _selected;
  bool? _isChecked;
  int? _selectedIndex;
  Map<String, dynamic>? _selectedTicket;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tickets = widget.event['tickets'] ?? [];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets for ${widget.event['event_name']}'),
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(widget.event['event_name'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text('Choose which tickets you would like to order'),
              const Spacer(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tickets?.length ?? 0,
                itemBuilder: (context, index) {
                  var ticket = tickets![index];
                  return SizedBox(
                    width: width(context),
                    child: ListTile(
                        title: Text(ticket['ticket_name']),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket.containsKey('price') ? '\$'
                                '${double.parse(ticket['price'].toString())
                                .toStringAsFixed
                              (2)}'
                                : 'Free'),
                          ],
                        ),
                        leading: Radio<int>(
                          value: index,
                          groupValue: _selected,
                          onChanged: (val) {
                            setState(() {
                              _selected = val;
                              _selectedTicket = ticket;
                              _selectedIndex = index;
                            });
                          },
                        ),
                        trailing:
                        ticket.containsKey('description') ? Tooltip
                          (message: ticket['description'], child: const
                        Icon
                          (Icons.info_outline)) :
                        const SizedBox(),
                  ));
                },
              ),
              const Spacer(flex: 3),
              CheckboxListTile(
                  value: _isChecked ?? false,
                  onChanged: (val) {
                    setState(() {
                      _isChecked = val;
                    });
                  },
                  subtitle: const Text('I confirm that I am liable to the Terms and '
                      'Conditions of this purchase and all other regulations set.')),
              const Spacer(flex: 3),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  Text(
                      _selectedTicket == null
                          ? '\$ 0.00'
                          : '\$ ${double.parse(_selectedTicket!['price'].toString()).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_selectedTicket != null &&
                            _selected != null &&
                            _isChecked == true) {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text(
                                  'I would like to pay by',
                                  textAlign: TextAlign.center,
                                ),
                                content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            showSnackbar(
                                                context, 'Not configured');
                                          },
                                          child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.credit_card_outlined,
                                                    size: 40),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Personal Wallet',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ]),
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      const Text('OR'),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (_) => Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        30),
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                            'Deduct \$${double.parse(_selectedTicket!['price'].toString()).toStringAsFixed(2)} from your WazzLitt account',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize: 20)),
                                                        const SizedBox(height: 60),
                                                        const Text(
                                                            'Confirm that you would like to deduct this amount from your balance.'),
                                                        const SizedBox(height: 60),
                                                        Row(
                                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                                width: width(
                                                                    context) *
                                                                    0.4,
                                                                child:
                                                                ElevatedButton(
                                                                  child: Text('Pay \$${double.parse(_selectedTicket!['price']
                                                                          .toString())
                                                                          .toStringAsFixed(
                                                                          2)}'),
                                                                  onPressed:
                                                                      () {
                                                                    payFromBalance(double.parse(_selectedTicket!['price'].toString()), context).then((paymentStatus) {
                                                                      print(paymentStatus ?? 'No payment info found');
                                                                      if (paymentStatus == 'paid') {
                                                                        uploadEventOrder(_selectedTicket!,_selectedIndex!, widget.event, 'wazzlitt_balance').then((value) => Navigator.popAndPushNamed(context, 'confirmed'));
                                                                      } else {
                                                                        Navigator.pop(context);
                                                                        showSnackbar(context, 'Something went wrong with your payment. Please check your balance or try again later');
                                                                      }
                                                                    });
                                                                  },
                                                                )),
                                                            TextButton(
                                                                child: const Text(
                                                                    'Cancel'),
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop()),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                            child: const Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .monetization_on_outlined,
                                                      size: 40),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'WazzLitt Wallet',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ]),
                                          )),
                                    ]),
                              ));
                        } else {
                          showSnackbar(context,
                              'Please select a service and agree to the terms');
                        }
                      },
                      child: const Text('Checkout'))),
              const Spacer(flex: 5),
            ]),
          )),
    );
  }
}