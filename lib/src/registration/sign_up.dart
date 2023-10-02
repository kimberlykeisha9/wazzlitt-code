import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:animate_do/animate_do.dart';
import '../../user_data/user_data.dart';
import '../../user_data/patrone_data.dart';
import '../app.dart';

class PhoneNumberPrompt extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final PageController pageController;

  PhoneNumberPrompt({
    required this.formKey,
    required this.phoneController,
    required this.pageController,
  });

  @override
  State<PhoneNumberPrompt> createState() => _PhoneNumberPromptState();
}

class PhoneVerification extends StatefulWidget {
  final PageController pageController;

  PhoneVerification({
    required this.pageController,
  });

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class SignUp extends StatefulWidget {
  SignUp();

  @override
  State<SignUp> createState() => _SignUpState();
}

class _PhoneNumberPromptState extends State<PhoneNumberPrompt> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZoomIn(
          duration: const Duration(milliseconds: 200),
          child: Text(
            AppLocalizations.of(context)!.verifyPhone,
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        Form(
          key: widget.formKey,
          child: ZoomIn(
            duration: const Duration(milliseconds: 300),
            child: IntlPhoneField(
            
              controller: widget.phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phone,
                border: InputBorder.none,
              ),
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
        ),
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: width(context),
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (widget.formKey.currentState!.validate()) {
                  getData('phone').then((number) => signInWithPhoneNumber(
                        number ?? '',
                        context,
                        widget.pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        ),
                      ));
                }
              },
              child: Text(
                AppLocalizations.of(context)!.proceed,
              ),
            ),
          ),
        ),
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 700),
          child: Text(
            AppLocalizations.of(context)!.acceptTerms,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final _verificationController = TextEditingController();
  String? _phoneNumber;

  @override
  void dispose() {
    super.dispose();
    _verificationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getData('phone').then((value) {
      setState(() {
        _phoneNumber = value;
      });
    });
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Column(
      children: [
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 200),
          child: Text(
            'A verification code will be sent to $_phoneNumber',
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 300),
          child: const Text(
            'Please enter it in the space below',
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 400),
          child: TextButton(
            child: const Text('Change phone number'),
            onPressed: () {
              widget.pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        const Spacer(),
        ZoomIn(
          duration: const Duration(milliseconds: 500),
          child: PinCodeTextField(
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
            onChanged: (val) {},
          ),
        ),
        const Spacer(flex: 5),
        ZoomIn(
          duration: const Duration(milliseconds: 600),
          child: SizedBox(
            width: width(context),
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                try {
                  dataSendingNotifier.startLoading();
                  if (dataSendingNotifier.isLoading) {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()));
                  }

                  getData('verificationID')
                      .then((value) =>
                          verifyCode(_verificationController.text, value!))
                      .then((value) {
                        if (value != null) {
                          Navigator.popAndPushNamed(
                              context, 'dashboard');
                        } else {
                          dataSendingNotifier.stopLoading();
                          showSnackbar(context,
                              'Something went wrong. Please try again later');
                        }
                    
                  });
                  dataSendingNotifier.stopLoading();
                } on Exception catch (e) {
                  dataSendingNotifier.stopLoading();
                }
              },
              child: const Text('Verify'),
            ),
          ),
        ),
        const Spacer(flex: 10),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getData('phone').then((value) => _phoneNumber = value);
  }
}

class _SignUpState extends State<SignUp> {
  late String _direction = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    _formKey.currentState?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              PhoneNumberPrompt(
                formKey: _formKey,
                phoneController: _phoneController,
                pageController: _pageController,
              ),
              PhoneVerification(
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
