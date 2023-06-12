import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String _direction = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.verifyPhone,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              TextFormField(
                maxLength: 9,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phone,
                    border: InputBorder.none),
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_direction == 'patrone') {
                        Navigator.pushNamed(context, 'patrone_registration');
                      } else if (_direction == 'igniter') {
                        Navigator.pushNamed(context, 'igniter_registration');
                      } else {
                        showSnackbar(context, 'Something went wrong');
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
          ),
        ),
      ),
    );
  }
}
