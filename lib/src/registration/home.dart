import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../app.dart';

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
        child: Column(
          children: [
            const Spacer(
              flex: 20,
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                AppLocalizations.of(context)!.homeTitle,
                style: const TextStyle(
                    fontSize: 24,
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
                  onPressed: () => Navigator.pushNamed(context, 'signup'),
                  child: Text(
                    'Sign in with mobile',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
