import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wazzlitt/authorization/authorization.dart';

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
        future: currentUserPatroneProfile.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            return Container(
                height: height(context),
                width: width(context) * 0.75,
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.surface,
                child: Column(children: [
                  Container(
                    width: width(context),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WazzLitt Balance'),
                        SizedBox(height: 5),
                        Text(
                            userData.containsKey('balance')
                                ? '\$ ${double.parse(userData!['balance'].toString()).toStringAsFixed(2)}'
                                : '\$ 0.00',
                            style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 20,
                          width: 50,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            child: const Text('Top Up'),
                            onPressed: () {
                              topUp(context, topUpController);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
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
                  isIgniter != null
                      ? GestureDetector(
                    onTap: () => isIgniter!
                        ? Navigator.popAndPushNamed(
                        context,
                        ''
                            'igniter_dashboard')
                        : Navigator.pushNamed(
                        context,
                        'igni'
                            'ter_registration'),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.bolt),
                        SizedBox(width: 10),
                        Text(isIgniter!
                            ? 'Go to Igniter Profile'
                            : 'Create an '
                            'Igniter profile'),
                      ],
                    ),
                  )
                      : const SizedBox(),
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
          }
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }

  Future<dynamic> topUp(BuildContext context, TextEditingController topUpController) {
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
                        topUpAccount(double.parse(topUpController.text)).then((value) => Navigator.of(context).pop());
                      }
                    },
                  )
                ]));
  }
}
