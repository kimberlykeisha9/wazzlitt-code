import 'package:flutter/material.dart';
import '../app.dart';
import 'package:wazzlitt/authorization/authorization.dart';

class ConfirmedOrder extends StatefulWidget {
  const ConfirmedOrder({super.key});

  @override
  State<ConfirmedOrder> createState() => _ConfirmedOrderState();
}

class _ConfirmedOrderState extends State<ConfirmedOrder> {
  @override
  void initState() {
    super.initState();
    if (!isLoggedIn()) {
      Navigator.popAndPushNamed(context, 'home');
    }
  }

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
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://corsproxy.io/?https://i.pinimg.com/236x/91/0e/08/910e08a5ce36f96097423af6f8af99dd.jpg'),
                    fit: BoxFit.cover,
                  ))),
          const Spacer(),
          const Text('It\'s Litt!!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text(
              'You have successfully placed your order for **ORDER**. Check '
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
