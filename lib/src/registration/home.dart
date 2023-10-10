import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app.dart';
import 'package:animate_do/animate_do.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/home-image.png',
              )),
        ),
        height: height(context),
        width: width(context),
        child: SafeArea(
        child: Column(
          children: [
            ZoomIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                'Welcome to',
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white),
              ),
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                'WazzLitt!',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Spacer(
              flex: 20,
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                AppLocalizations.of(context)!.homeTitle,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Spacer(),
            ZoomIn(
              duration: const Duration(milliseconds: 400),
              child: SizedBox(
                width: width(context),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'signup', arguments: ('patrone')),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.phone, size: 16),
                      SizedBox(width: 10),
                      Text(
                        'Sign in with Phone',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            ZoomIn(
              duration: const Duration(milliseconds: 500),
              child: SizedBox(
                width: width(context),
                child: ElevatedButton(
                  onPressed: () => showSnackbar(context, 'Not currently available'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: 
                    [
                      Icon(FontAwesomeIcons.google, size: 16),
                      SizedBox(width: 10),
                      Text(
                        'Sign in with Google',
                      ),
                    ],
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
