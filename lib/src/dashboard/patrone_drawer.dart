import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/authorization/authorization.dart';

import '../../user_data/patrone_data.dart';
import '../../user_data/user_data.dart';
import '../app.dart';

class PatroneDrawer extends StatefulWidget {
  const PatroneDrawer({
    super.key,
  });

  @override
  State<PatroneDrawer> createState() => _PatroneDrawerState();
}

class _PatroneDrawerState extends State<PatroneDrawer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String igniterButtonText = '';
  bool? isIgniter;
  TextEditingController topUpController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfIgniterUser().then((igniter) {
      if (igniter == true) {
        setState(() {
          isIgniter = igniter;
        });
      } else if (igniter == false) {
        setState(() {
          isIgniter = igniter;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<DocumentSnapshot>(
          future: null,
          builder: (context, snapshot) {
            return Container(
                height: height(context),
                width: width(context) * 0.75,
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'settings'),
                    child: const Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 10),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'orders'),
                    child: const Row(
                      children: [
                        Icon(FontAwesomeIcons.bagShopping),
                        SizedBox(width: 10),
                        Text('Orders'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => signOut()
                        .then((value) => Navigator.pushNamed(context, 'home')),
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Log Out'),
                      ],
                    ),
                  ),
                ]));
          }),
    );
  }

  Future<dynamic> topUp(
      BuildContext context, TextEditingController topUpController) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top up WazzLitt wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'How much money would you like to top up to your WazzLitt account?'),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.always,
                controller: topUpController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (!RegExp(r'(\d+)').hasMatch(val)) {
                    return 'Please enter numeric digits';
                  }
                  if (double.parse(val) < 10) {
                    return 'Minimum top up is \$10';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Top up'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Provider.of<Patrone>(context)
                    .topUpAccount(double.parse(topUpController.text))
                    .then((value) => Navigator.of(context).pop());
              }
            },
          )
        ],
      ),
    );
  }
}
