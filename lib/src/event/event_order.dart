import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/order_data.dart';
import 'package:wazzlitt/user_data/payments.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
import 'dart:developer';

class EventOrder extends StatefulWidget {
  const EventOrder({super.key, required this.event});

  final EventData event;

  @override
  State<EventOrder> createState() => _EventOrderState();
}

class _EventOrderState extends State<EventOrder> {
  List<Ticket>? tickets = [];
  int? _selected;
  bool? _isChecked;
  int? _selectedIndex;
  Ticket? _selectedTicket;

  @override
  void initState() {
    super.initState();
    tickets = widget.event.tickets ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets for ${widget.event.eventName}'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(widget.event.eventName ?? '',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    title: Text(ticket.title ?? ''),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.price != null
                            ? '\$'
                                '${double.parse(ticket.price.toString()).toStringAsFixed(2)}'
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
                    trailing: ticket.description != null
                        ? Tooltip(
                            message: ticket.description,
                            child: const Icon(Icons.info_outline))
                        : const SizedBox(),
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
              subtitle: const Text(
                  'I confirm that I am liable to the Terms and '
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
                      : '\$ ${double.parse(_selectedTicket!.price.toString()).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
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
                                          onTap: () async {
                                            Navigator.of(context).pop();
                                            await launchUrl(
                                                Uri.parse(
                                                    '${_selectedTicket!.paymentURL!}?client_reference_id=${auth.currentUser!.uid}-order-${widget.event.eventReference!.id}'),
                                                webOnlyWindowName: '_blank').then((value) {
                                                  Future.delayed(Duration(minutes: 2), () {
                                                    checkIfOrderIsSuccess(widget.event.eventReference!.id).then((value) {
                                                      if (value != null) {
                                                        log(value.toString());
                                                        Order().uploadEventOrder(_selectedTicket!, _selectedIndex!, widget.event, 'stripe', value);
                                                      }
                                                    });
                                                  });
                                                });
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
                                                            'Deduct \$${double.parse(_selectedTicket!.price.toString()).toStringAsFixed(2)} from your WazzLitt account',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20)),
                                                        const SizedBox(
                                                            height: 60),
                                                        const Text(
                                                            'Confirm that you would like to deduct this amount from your balance.'),
                                                        const SizedBox(
                                                            height: 60),
                                                        Row(
                                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                                width: width(
                                                                        context) *
                                                                    0.4,
                                                                child:
                                                                    ElevatedButton(
                                                                  child: Text(
                                                                      'Pay \$${double.parse(_selectedTicket!.price.toString()).toStringAsFixed(2)}'),
                                                                  onPressed:
                                                                      () {
                                                                    try {
                                                                      dataSendingNotifier
                                                                          .startLoading();
                                                                      if (dataSendingNotifier
                                                                          .isLoading) {
                                                                        showDialog(
                                                                            barrierDismissible:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                            builder: (_) =>
                                                                                const Center(child: CircularProgressIndicator()));
                                                                      }

                                                                      payFromBalance(
                                                                              double.parse(_selectedTicket!.price.toString()),
                                                                              context)
                                                                          .then((paymentStatus) {
                                                                        log(paymentStatus ??
                                                                            'No payment info found');
                                                                        if (paymentStatus ==
                                                                            'paid') {
                                                                          // Order().uploadEventOrder(_selectedTicket!, _selectedIndex!, widget.event, 'wazzlitt_balance').then((value) => Navigator.popAndPushNamed(
                                                                          //     context,
                                                                          //     'confirmed'));
                                                                        } else {
                                                                          Navigator.pop(
                                                                              context);
                                                                          dataSendingNotifier
                                                                              .stopLoading();
                                                                          showSnackbar(
                                                                              context,
                                                                              'Something went wrong with your payment. Please check your balance or try again later');
                                                                        }
                                                                      });
                                                                      dataSendingNotifier
                                                                          .stopLoading();
                                                                    } on Exception {
                                                                      dataSendingNotifier
                                                                          .stopLoading();
                                                                    }
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
