import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import '../../authorization/authorization.dart';
import '../../user_data/payments.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import 'business_owner/business_owner_profile.dart';
import 'chats_view.dart';
import 'event_organizer/event_organizer_dashboard.dart';
import 'event_organizer/event_organizer_profile.dart';
import 'igniter_drawer.dart';

class IgniterDashboard extends StatefulWidget {
  const IgniterDashboard({super.key});

  @override
  State<IgniterDashboard> createState() => _IgniterDashboardState();
}

class _IgniterDashboardState extends State<IgniterDashboard> {
  var _currentIndex = 0;

  List<Widget> businessOwnerView(List<dynamic> listings) {
    return [
      BusinessOwnerDashboard(listings: listings),
      const ChatsView(chatType: ChatRoomType.business),
      BusinessOwnerProfile(listings: listings)
    ];
  }

  List<Widget> eventOrganizerView(List<dynamic> events) {
    return [
      EventOrganizerDashboard(events: events),
      const ChatsView(chatType: ChatRoomType.business),
      const EventOrganizerProfile()
    ];
  }

  bool? confirmedPayment;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _smsController = TextEditingController();
  GlobalKey<FormState> _emailKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: currentUserIgniterProfile.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> igniterData =
                  snapshot.data!.data() as Map<String, dynamic>;
                  bool isFreeTrial = !(igniterData['createdAt'] as Timestamp)
                            .toDate()
                            .add(Duration(days: 14))
                            .isBefore(DateTime.now());
              if (isFreeTrial ||
                            (igniterData.containsKey('igniter_payment') 
                            && (igniterData['igniter_payment']['expiration_date'] as Timestamp).toDate().isAfter(DateTime.now()))) {
                          confirmedPayment = true;
                          if (isFreeTrial == true) {
                            print('User is on free trial');
                          } else {
                            print('Trial period ended for the user');
                          }
              if(igniterData['igniter_type'] == 'business_owner') {
                List<dynamic> listings = igniterData['listings'];
                return businessOwnerView(listings)[_currentIndex];
              } else if (igniterData['igniter_type'] == 'event_organizer') {
                List<dynamic> events = igniterData['events'];
                return eventOrganizerView(events)[_currentIndex];
              }
            }
            } else {
                          confirmedPayment = false;
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      'You have not finished setting up your payment '
                                      'for the Igniter account. You can continue the '
                                      'set up process by pressing the button below',
                                      textAlign: TextAlign.center),
                                  auth.currentUser!.email == null
                                      ? SizedBox(height: 20)
                                      : SizedBox(),
                                  auth.currentUser!.email == null
                                      ? Text(
                                          'Please '
                                          'provide'
                                          ' a valid '
                                          'email '
                                          'address below',
                                          textAlign: TextAlign.center)
                                      : SizedBox(),
                                  auth.currentUser!.email == null
                                      ? SizedBox(height: 30)
                                      : SizedBox(),
                                  auth.currentUser!.email == null
                                      ? Form(
                                          key: _emailKey,
                                          child: TextFormField(
                                              controller: _emailController,
                                              autovalidateMode:
                                                  AutovalidateMode.always,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Email is required';
                                                }
                                                final emailRegex = RegExp(
                                                  r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)*[a-zA-Z]{2,7}$',
                                                );
                                                if (!(emailRegex
                                                    .hasMatch(value))) {
                                                  return 'Enter a valid email address';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Email Address',
                                              )),
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                      onPressed: () {
                                        if (auth.currentUser!.email == null) {
                                          if (_emailKey.currentState!
                                              .validate()) {
                                            auth.currentUser!
                                                .updateEmail(
                                                    _emailController.text)
                                                .then(
                                                    (value) => auth.currentUser!
                                                            .reload()
                                                            .then((value) {
                                                          payForIgniter(
                                                              context);
                                                        }), onError: (e) {
                                              signInWithPhoneNumber(
                                                  auth.currentUser!
                                                      .phoneNumber!,
                                                  context,
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Enter your '
                                                              'verification code'),
                                                          content:
                                                              PinCodeTextField(
                                                                  controller:
                                                                      _smsController,
                                                                  validator:
                                                                      (val) {
                                                                    if (val ==
                                                                        null) {
                                                                      return 'Please enter a value';
                                                                    }
                                                                    if (val.length !=
                                                                        6) {
                                                                      return 'Please enter a valid code';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  appContext:
                                                                      context,
                                                                  length: 6,
                                                                  onChanged:
                                                                      (val) {}),
                                                          actions: [
                                                            TextButton(
                                                                child: Text(
                                                                    'Verify'),
                                                                onPressed: () {
                                                                  getData('verificationID').then((value) => verifyCode(
                                                                          _smsController
                                                                              .text,
                                                                          value!)
                                                                      .then((value) =>
                                                                          null));
                                                                })
                                                          ],
                                                        );
                                                      }));
                                            });
                                          }
                                        } else {
                                          payForIgniter(context);
                                        }
                                      },
                                      child: Text('Pay for Igniter Account')),
                                ]),
                          );
                        }
            return const Center(child: CircularProgressIndicator());
          }),
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Theme.of(context).colorScheme.primary,
        ),
        child: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Messages', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
          ],
        ),
      ),
    );
  }
}
