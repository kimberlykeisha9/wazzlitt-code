import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/payments.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../user_data/order_data.dart';
import '../app.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({Key? key, required this.place});

  final Map<String, dynamic> place;

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  List<dynamic>? services = [];
  int? _selected;
  bool? _isChecked;
  Map<String, dynamic>? _selectedService;

  @override
  void initState() {
    super.initState();
    services = widget.place['services'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Services for ${widget.place['place_name']}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                widget.place['place_name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              const Text('Choose which services you would like to order'),
              Spacer(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: services?.length,
                  itemBuilder: (context, index) {
                    var service = services![index];
                    return ListTile(
                      leading: Radio<int>(
                        value: index,
                        groupValue: _selected,
                        onChanged: (val) {
                          setState(() {
                            _selected = val;
                            _selectedService = service;
                          });
                        },
                      ),
                      title: Text(service['service_name']),
                      subtitle: Text(
                        '\$ ${double.parse(service['price'].toString()).toStringAsFixed(2)}',
                      ),
                      trailing: service.containsKey('service_description')
                          ? Tooltip(
                              message: service['service_description'],
                              child: const Icon(Icons.info_outline),
                            )
                          : SizedBox(),
                    );
                  },
                ),
              ),
              Spacer(flex: 3),
              CheckboxListTile(
                value: _isChecked ?? false,
                onChanged: (val) {
                  setState(() {
                    _isChecked = val;
                  });
                },
                subtitle: const Text(
                  'I confirm that I am liable to the Terms and Conditions of this purchase and all other regulations set.',
                ),
              ),
              Spacer(flex: 3),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  Text(
                    _selectedService == null
                        ? '\$ 0.00'
                        : '\$ ${double.parse(_selectedService!['price'].toString()).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedService != null && _selected != null && _isChecked == true) {
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
                                    showSnackbar(context, 'Not configured');
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.credit_card_outlined,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Personal Wallet',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
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
                                        padding: const EdgeInsets.all(30),
                                        child: Wrap(
                                          children: [
                                            Text(
                                              'Deduct \$${double.parse(_selectedService!['price'].toString()).toStringAsFixed(2)} from your WazzLitt account',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 60),
                                            const Text(
                                              'Confirm that you would like to deduct this amount from your balance.',
                                            ),
                                            const SizedBox(height: 60),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: width(context) * 0.4,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      try {
                                                        dataSendingNotifier.startLoading();
 if (dataSendingNotifier.isLoading) {
   showDialog(
    barrierDismissible: false,
       context: context,
    builder: (_) => const Center(
    child: CircularProgressIndicator()));
 }

  payFromBalance(double.parse(_selectedService!['price'].toString()), context).then((paymentStatus) {
    print(paymentStatus ?? 'No payment info found');
    if (paymentStatus == 'paid') {
      Order().uploadPlaceOrder(_selectedService!, widget.place, 'wazzlitt_balance').then((value) => Navigator.popAndPushNamed(context, 'confirmed'));
    } else {
      Navigator.pop(context);
      dataSendingNotifier.stopLoading();
      showSnackbar(context, 'Something went wrong with your payment. Please check your balance or try again later');
    }
  });
  dataSendingNotifier.stopLoading();
} on Exception catch (e) {
  dataSendingNotifier.stopLoading();
}
                                                    },
                                                    child: Text('Pay \$${double.parse(_selectedService!['price'].toString()).toStringAsFixed(2)}'),
                                                  ),
                                                ),
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.monetization_on_outlined,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'WazzLitt Wallet',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      showSnackbar(context, 'Please select a service and agree to the terms');
                    }
                  },
                  child: const Text('Checkout'),
                ),
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
