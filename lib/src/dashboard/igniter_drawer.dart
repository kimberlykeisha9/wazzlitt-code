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
          color: Colors.white,
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
                    Text('WazzLitt Balance'),
                    Text('\$0.00',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                            SizedBox(height: 10),
                    SizedBox(
                      height: 20,
                      width: 50,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0)),
                          child: Text('Top Up'),
                          onPressed: () {},),
                    )
                  ],),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap:() => Navigator.pushNamed(context, 'settings'),
              child: Row(
                children: const [
                  Icon(Icons.settings),
                  SizedBox(width: 10),
                  Text('Settings'),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap:() => Navigator.pushNamed(context, 'orders'),
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.bagShopping),
                  SizedBox(width: 10),
                  Text('Orders'),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap:() => Navigator.popAndPushNamed(context, 'patrone_dashboard'),
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.bolt),
                  SizedBox(width: 10),
                  Text('Switch to Patrone Profile'),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap:() => Navigator.pushNamed(context, 'home'),
              child: Row(
                children: const [
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
