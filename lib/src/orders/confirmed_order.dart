import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app.dart';

class ConfirmedOrder extends StatelessWidget {
  const ConfirmedOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          const Spacer(flex: 4),
          const Icon(FontAwesomeIcons.champagneGlasses, size: 60),
          const Spacer(),
          const Text('It\'s Litt!!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text('You have successfully placed your order for **ORDER**. Check '
              'your email for an invoice and the orders panel for your '
              'transaction details.'),
          const Spacer(),
          SizedBox(
              width: width(context),
              child: ElevatedButton(
                  child: const Text('Return to home'),
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          const Spacer(flex: 4),
        ]),
      ),
    );
  }
}
