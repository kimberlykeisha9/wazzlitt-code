import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app.dart';

class IgniterDrawer extends StatelessWidget {
  const IgniterDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                    const Text('\$0.00',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 10),
                    SizedBox(
                      height: 20,
                      width: 50,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0)),
                          child: const Text('Top Up'),
                          onPressed: () {},),
                    )
                  ],),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap:() => Navigator.pushNamed(context, 'settings'),
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
              onTap:() => Navigator.pushNamed(context, 'orders'),
              child: const Row(
                children: [
                  Icon(FontAwesomeIcons.bagShopping),
                  SizedBox(width: 10),
                  Text('Orders'),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap:() => Navigator.popAndPushNamed(context, 'patrone_dashboard'),
              child: const Row(
                children: [
                  Icon(FontAwesomeIcons.bolt),
                  SizedBox(width: 10),
                  Text('Switch to Patrone Profile'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap:() => Navigator.pushNamed(context, 'home'),
              child: const Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Log Out'),
                ],
              ),
            ),
          ])),
    );
  }
}
