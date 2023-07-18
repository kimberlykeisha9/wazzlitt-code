import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wazzlitt/authorization/authorization.dart';

import '../../user_data/user_data.dart';
import '../app.dart';

class PhoneNumberPrompt extends StatefulWidget {
  final GlobalKey<FormState> _formKey;

  final TextEditingController _phoneController;
  final PageController _pageController;
  const PhoneNumberPrompt(
      {super.key,
      required GlobalKey<FormState> formKey,
      required TextEditingController phoneController,
      required PageController pageController})
      : _formKey = formKey,
        _phoneController = phoneController,
        _pageController = pageController;

  @override
  State<PhoneNumberPrompt> createState() => _PhoneNumberPromptState();
}

class PhoneVerification extends StatefulWidget {
  final String _direction;

  final PageController _pageController;
  const PhoneVerification({
    super.key,
    required String direction,
    required PageController pageController,
  })  : _direction = direction,
        _pageController = pageController;

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _PhoneNumberPromptState extends State<PhoneNumberPrompt> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.verifyPhone,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Form(
          key: widget._formKey,
          child: IntlPhoneField(
            controller: widget._phoneController,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phone,
                border: InputBorder.none),
            keyboardType: TextInputType.number,
            onChanged: (phone) {
              storeData('phone', phone.completeNumber);
            },
            validator: (value) {
              if (value == null) {
                return 'Phone number is required';
              }
              return null; // Return null if the input is valid
            },
          ),
        ),
        const Spacer(),
        SizedBox(
            width: width(context),
            child: ElevatedButton(
              onPressed: () {
                if (widget._formKey.currentState!.validate()) {
                  getData('phone').then((number) => signInWithPhoneNumber(
                      number ?? '',
                      context,
                      widget._pageController.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      )));
                }
              },
              child: Text(
                AppLocalizations.of(context)!.proceed,
              ),
            )),
        const Spacer(),
        Text(
          AppLocalizations.of(context)!.googleSignIn,
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.google),
          onPressed: () {},
        ),
        const Spacer(flex: 2),
        Text(
          AppLocalizations.of(context)!.acceptTerms,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final _verificationController = TextEditingController();
  String? _phoneNumber;

  @override
  Widget build(BuildContext context) {
    getData('phone').then((value) => _phoneNumber == value);
    return Column(
      children: [
        Spacer(),
        Text(
          'A verification code will be sent to $_phoneNumber',
          textAlign: TextAlign.center,
        ),
        Spacer(),
        Text(
          'Please enter it in the space below',
          textAlign: TextAlign.center,
        ),
        Spacer(),
        TextButton(
          child: Text('Change phone number'),
          onPressed: () {
            widget._pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut);
          },
        ),
        Spacer(),
        PinCodeTextField(
            controller: _verificationController,
            validator: (val) {
              if (val == null) {
                return 'Please enter a value';
              }
              if (val.length != 6) {
                return 'Please enter a valid code';
              }
              return null;
            },
            keyboardType: TextInputType.number,
            appContext: context,
            length: 6,
            onChanged: (val) {}),
        Spacer(flex: 5),
        SizedBox(
          width: width(context),
          child: ElevatedButton(
            onPressed: () {
              getData('verificationID')
                  .then((value) =>
                      verifyCode(_verificationController.text, value!))
                  .then((value) => {
                        if (widget._direction == 'patrone')
                          {
                            checkIfPatroneUser().then((isPatrone) {
                              if (isPatrone == true) {
                                Navigator.popAndPushNamed(
                                    context, 'patrone_dashboard');
                              } else if (isPatrone == false) {
                                Navigator.pushNamed(
                                    context, 'patrone_registration');
                              } else {
                                showSnackbar(context,
                                    'Something went wrong. Please try again  later');
                              }
                            })
                          }
                        else if (widget._direction == 'igniter') {
                            checkIfIgniterUser().then((isIgniter) {
                              if (isIgniter == true) {
                                Navigator.popAndPushNamed(
                                    context, 'igniter_dashboard');
                              } else if (isIgniter == false) {
                                Navigator.pushNamed(
                                    context, 'igniter_registration');
                              } else {
                                showSnackbar(
                                    context,
                                    'Something went '
                                    'wrong. Please try again  later');
                              }
                            }),
                          }
                        else
                          {showSnackbar(context, 'Something went wrong.')}
                      });
            },
            child: Text('Verify'),
          ),
        ),
        Spacer(flex: 10),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData('phone').then((value) => _phoneNumber == value);
  }
}

class _SignUpState extends State<SignUp> {
  late String _direction = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              PhoneNumberPrompt(
                formKey: _formKey,
                phoneController: _phoneController,
                pageController: _pageController,
              ),
              PhoneVerification(
                direction: _direction,
                pageController: _pageController,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      setState(() {
        if (kDebugMode) {
          print(_direction);
        }
        _direction = ModalRoute.of(context)!.settings.arguments as String;
      });
    });
  }
}
