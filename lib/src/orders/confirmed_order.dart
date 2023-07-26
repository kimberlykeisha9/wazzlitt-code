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
          const Spacer(flex: 2),
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/236x/91/0e/08/910e08a5ce36f96097423af6f8af99dd.jpg'),
                fit: BoxFit.cover,
              )
            )
          ),
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
