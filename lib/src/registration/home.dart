import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
        child: Column(
          children: [
            const Spacer(
              flex: 20,
            ),
            ZoomIn(
              duration: Duration(milliseconds: 300),
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
              duration: Duration(milliseconds: 400),
              child: SizedBox(
                width: width(context),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'signup', arguments: ('patrone')),
                  child: Text(
                    AppLocalizations.of(context)!.patrone,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ZoomIn(
              duration: Duration(milliseconds: 500),
              child: SizedBox(
                width: width(context),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, 'signup', arguments: ('igniter')),
                  child: Text(
                    AppLocalizations.of(context)!.igniter,
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
