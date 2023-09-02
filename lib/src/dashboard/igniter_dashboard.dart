import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import '../../authorization/authorization.dart';
import '../../user_data/business_owner_data.dart';
import '../../user_data/igniter_data.dart';
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

  List<Widget> businessOwnerView = [
      BusinessOwnerDashboard(),
      const ChatsView(chatType: ChatRoomType.business),
      BusinessOwnerProfile()
    ];

  List<Widget> eventOrganizerView = [
      EventOrganizerDashboard(),
      const ChatsView(chatType: ChatRoomType.business),
      const EventOrganizerProfile()
    ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Igniter>(context).getCurrentUserIgniterInformation();
  }

  bool? confirmedPayment;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _smsController = TextEditingController();
  GlobalKey<FormState> _emailKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var igniterData = Provider.of<Igniter>(context);
    bool isFreeTrial = !(igniterData.dateCreated!
        .add(const Duration(days: 14))
        .isBefore(DateTime.now()));
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: (isFreeTrial ||
                  (igniterData.igniterPayment != null &&
                      (igniterData.igniterPayment!['expiration_date']
                              as Timestamp)
                          .toDate()
                          .isAfter(DateTime.now()))) ? (igniterData
          .igniterType == IgniterType.businessOwner) ?
      businessOwnerView[_currentIndex]
                : eventOrganizerView[_currentIndex]  : Padding(
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
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)*[a-zA-Z]{2,7}$',
                                    );
                                    if (!(emailRegex.hasMatch(value))) {
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
                              if (_emailKey.currentState!.validate()) {
                                auth.currentUser!
                                    .updateEmail(_emailController.text)
                                    .then(
                                        (value) => auth.currentUser!
                                                .reload()
                                                .then((value) {
                                              payForIgniter(context);
                                            }), onError: (e) {
                                  signInWithPhoneNumber(
                                      auth.currentUser!.phoneNumber!,
                                      context,
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: Text('Enter your '
                                                  'verification code'),
                                              content: PinCodeTextField(
                                                  controller: _smsController,
                                                  validator: (val) {
                                                    if (val == null) {
                                                      return 'Please enter a value';
                                                    }
                                                    if (val.length != 6) {
                                                      return 'Please enter a valid code';
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  appContext: context,
                                                  length: 6,
                                                  onChanged: (val) {}),
                                              actions: [
                                                TextButton(
                                                    child: Text('Verify'),
                                                    onPressed: () {
                                                      getData('verificationID').then(
                                                          (value) => verifyCode(
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
              ),
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
