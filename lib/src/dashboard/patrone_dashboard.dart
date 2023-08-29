import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/dashboard/profile_screen.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../../user_data/payments.dart';
import '../app.dart';
import '../../user_data/patrone_data.dart';
import 'dart:io';
import '../location/location.dart';
import 'chats_view.dart';
import 'explore.dart';
import 'feed.dart';
import 'patrone_drawer.dart';
import 'upload_image.dart';

class PatroneDashboard extends StatefulWidget {
  const PatroneDashboard({super.key});

  @override
  State<PatroneDashboard> createState() => _PatroneDashboardState();
}

class _PatroneDashboardState extends State<PatroneDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _exploreController;

  bool? confirmedPayment;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _smsController = TextEditingController();
  GlobalKey<FormState> _emailKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // uploadLocation();
    _exploreController = TabController(length: 2, vsync: this);
    Provider.of<Patrone>(context).getCurrentUserPatroneInformation();
  }

  List<Widget> views(BuildContext context) {
    return [
      const Feed(),
      Explore(
        tabController: _exploreController!,
      ),
      const ChatsView(chatType: ChatRoomType.individual),
      ProfileScreen(
        userProfile: Provider.of<Patrone>(context).currentUserPatroneProfile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PatroneDrawer(),
      appBar: AppBar(
        title: titleWidget(context),
        actions: [
          (confirmedPayment ?? false)
              ? (trailingIcon() ?? const SizedBox())
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                    stream: null,
                    builder: (context, snapshot) {
                      bool isFreeTrial = !(Provider.of<Patrone>(context)
                          .createdTime!
                          .add(const Duration(days: 14))
                          .isBefore(DateTime.now()));
                      if (isFreeTrial ||
                          (Provider.of<Patrone>(context)
                                  .patronePayment!
                                  .containsKey('patrone_payment') &&
                              (Provider.of<Patrone>(context)
                                          .patronePayment!['patrone_payment']
                                      ['expiration_date'] as Timestamp)
                                  .toDate()
                                  .isAfter(DateTime.now()))) {
                        confirmedPayment = true;
                        if (isFreeTrial == true) {
                          print('User is on free trial');
                        } else {
                          print('Trial period ended for the user');
                        }
                        return views(context)[_currentIndex];
                      } else {
                        confirmedPayment = false;
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                    'You have not finished setting up your payment '
                                    'for the patrone account. You can continue the '
                                    'set up process by pressing the button below',
                                    textAlign: TextAlign.center),
                                auth.currentUser!.email == null
                                    ? const SizedBox(height: 20)
                                    : const SizedBox(),
                                auth.currentUser!.email == null
                                    ? const Text(
                                        'Please provide a valid email address below',
                                        textAlign: TextAlign.center)
                                    : const SizedBox(),
                                auth.currentUser!.email == null
                                    ? const SizedBox(height: 30)
                                    : const SizedBox(),
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
                                            decoration: const InputDecoration(
                                              labelText: 'Email Address',
                                            )),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 20),
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
                                                        payForPatrone(context);
                                                      }), onError: (e) {
                                            signInWithPhoneNumber(
                                                auth.currentUser!.phoneNumber!,
                                                context,
                                                showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      return AlertDialog(
                                                        title: const Text(
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
                                                              child: const Text(
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
                                        payForPatrone(context);
                                      }
                                    },
                                    child: const Text('Pay for Patrone Account')),
                              ]),
                        );
                      }
                    })),
          ],
        ),
      ),
      bottomNavigationBar: (confirmedPayment ?? false)
          ? Theme(
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
                  BottomNavigationBarItem(
                      label: 'Home', icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: 'Explore', icon: Icon(Icons.explore)),
                  BottomNavigationBarItem(
                      label: 'Messages', icon: Icon(Icons.chat)),
                  BottomNavigationBarItem(
                      label: 'Profile', icon: Icon(Icons.account_circle)),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  File? _toBeUploaded;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _toBeUploaded = File(pickedFile.path);
      });
      print("Image Path: ${pickedFile.path}");
    }
  }

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            _getImage().then((value) => _toBeUploaded != null
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UploadImage(uploadedImage: _toBeUploaded!),
                    ),
                  )
                : null);
          },
          icon: const Icon(Icons.photo_camera),
        );
      case 1:
        return IconButton(
          onPressed: () => Navigator.pushNamed(context, 'search'),
          icon: const Icon(Icons.search),
        );
    }
    return null;
  }

  Widget? titleWidget(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const Text('WazzLitt! around me');
      case 1:
        return TabBar(
          unselectedLabelStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
          indicatorColor: Theme.of(context).colorScheme.primary,
          controller: _exploreController,
          tabs: const [Tab(text: 'Lit'), Tab(text: 'Places')],
        );
      case 2:
        return const Text('Messages');
      case 3:
        return const Text('Profile');
    }
    return null;
  }
}
