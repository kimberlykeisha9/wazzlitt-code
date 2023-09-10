import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/igniter_dashboard.dart';
import 'package:wazzlitt/src/dashboard/patrone_dashboard.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../app.dart';


class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: currentUserProfile.get(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            Map<String, dynamic>? data =
                snapshot.data!.data() as Map<String, dynamic>?;
            print(data);
            if (data != null && (data.containsKey('is_patrone') || data.containsKey('is_igniter'))) {
              if (data.containsKey('is_patrone') &&
                  data.containsKey('is_igniter')) {
                print('User is patrone and igniter');
                return Scaffold(
                  body: Container(
                    height: height(context),
                    width: width(context),
                    decoration: BoxDecoration(
                      image: moon,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(children: [
                          const Text(
                            'Welcome to WazzLitt!\n\nChoose which profile you would like to access',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      'https://i.pinimg.com/564x/64/61/b2/6461b26b889edc1fa4cc4016052a188e.jpg'),
                                ),
                              ),
                              child: Center(
                                  child: TextButton(
                                child: const Text('Patrone Profile',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white)),
                                onPressed: () => Navigator.popAndPushNamed(
                                    context, 'patrone_dashboard'),
                              )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        'https://i.pinimg.com/564x/d3/86/c4/d386c4ab5f1fe835952e46fc198ba240.jpg'),
                                  ),
                                ),
                                child: Center(
                                    child: TextButton(
                                  child: const Text('Igniter Profile',
                                      style: TextStyle(
                                          fontSize: 30, color: Colors.white)),
                                  onPressed: () => Navigator.popAndPushNamed(
                                      context, 'igniter_dashboard'),
                                ))),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              } else if (data.containsKey('is_patrone')) {
                print('User is patrone');
                return const PatroneDashboard();
              } else if (data.containsKey('is_igniter')) {
                print('User is igniter');
                return const IgniterDashboard();
              }
            } else {
              return Scaffold(
                body: Container(
                  height: height(context),
                  width: width(context),
                  decoration: BoxDecoration(
                    image: moon,
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Text(
                                'You did not finish setting up your account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30),
                              Text(
                                'Which account type would you like to create?',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  'https://i.pinimg.com/564x/64/61/b2/6461b26b889edc1fa4cc4016052a188e.jpg',
                                ),
                              ),
                            ),
                            child: Center(
                              child: TextButton(
                                child: const Text('Patrone Profile',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white)),
                                onPressed: () => Navigator.popAndPushNamed(
                                    context, 'patrone_registration'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    'https://i.pinimg.com/564x/d3/86/c4/d386c4ab5f1fe835952e46fc198ba240.jpg'),
                              ),
                            ),
                            child: Center(
                              child: TextButton(
                                child: const Text('Igniter Profile',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white)),
                                onPressed: () => Navigator.popAndPushNamed(
                                    context, 'igniter_registration'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
          return Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()));
        });
  }
}
