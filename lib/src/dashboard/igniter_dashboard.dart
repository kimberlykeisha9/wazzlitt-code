import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/business_owner/business_owner_dashboard.dart';
import '../../authorization/authorization.dart';
import '../../user_data/business_owner_data.dart';
import '../../user_data/igniter_data.dart';
import '../../user_data/payments.dart';
import '../../user_data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    Provider.of<Igniter>(context, listen: false)
        .getCurrentUserIgniterInformation();
  }

  @override
  Widget build(BuildContext context) {
    var igniterData = Provider.of<Igniter>(context);
    bool isFreeTrial = !((igniterData.dateCreated ?? DateTime(2000))
        .add(const Duration(days: 14))
        .isBefore(DateTime.now()));
    return Scaffold(
      drawer: const IgniterDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: (isFreeTrial ||
              (igniterData.igniterPayment != null &&
                  (igniterData.igniterPayment!['expiration_date'] as Timestamp)
                      .toDate()
                      .isAfter(DateTime.now())))
          ? (igniterData.igniterType == IgniterType.businessOwner)
              ? businessOwnerView[_currentIndex]
              : eventOrganizerView[_currentIndex]
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'You have not finished setting up your payment '
                        'for the Igniter account. You can continue the '
                        'set up process by pressing the button below',
                        textAlign: TextAlign.center),
                    if (auth.currentUser!.email == null)
                      const SizedBox(height: 20),
                    if (auth.currentUser!.email == null)
                      const Text(
                          'Please '
                          'provide'
                          ' a valid '
                          'email '
                          'address below',
                          textAlign: TextAlign.center),
                    if (auth.currentUser!.email == null)
                      const SizedBox(height: 30),
                    if (auth.currentUser!.email == null)
                      Form(
                        key: GlobalKey<FormState>(),
                        child: TextFormField(
                          controller: TextEditingController(),
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
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (auth.currentUser!.email == null) {
                          if (GlobalKey<FormState>().currentState!.validate()) {
                            auth.currentUser!
                                .updateEmail(
                                    TextEditingController().text)
                                .then(
                                  (value) => auth.currentUser!
                                      .reload()
                                      .then(
                                        (value) {
                                          payForIgniter(context);
                                        },
                                      ),
                                )
                                .onError(
                                  (e, j) {
                                    signInWithPhoneNumber(
                                      auth.currentUser!.phoneNumber!,
                                      context,
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Enter your verification code'),
                                            content: PinCodeTextField(
                                              controller:
                                                  TextEditingController(),
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
                                              onChanged: (val) {},
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text('Verify'),
                                                onPressed: () {
                                                  getData('verificationID')
                                                      .then((value) =>
                                                          verifyCode(
                                                                  TextEditingController()
                                                                      .text,
                                                                  value!)
                                                              .then((value) =>
                                                                  null));
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                          }
                        } else {
                          payForIgniter(context);
                        }
                      },
                      child: const Text('Pay for Igniter Account'),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Container(
                constraints: const BoxConstraints(maxWidth: 375),
                child: DotNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          currentIndex: _currentIndex,
                  onTap: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  borderRadius: 15,
          items: [
            DotNavigationBarItem(icon: const Icon(Icons.home)),
            DotNavigationBarItem(icon: const Icon(Icons.chat)),
            DotNavigationBarItem(icon: const Icon(Icons.account_circle)),
          ],
        ),
              ),
       );
  }

  List eventOrganizerView = [EventOrganizerDashboard(), const ChatsView(chatType: ChatRoomType.business),  EventOrganizerProfile()];

  List businessOwnerView = [BusinessOwnerDashboard(), const ChatsView(chatType: ChatRoomType.business),  BusinessOwnerProfile()];
}
