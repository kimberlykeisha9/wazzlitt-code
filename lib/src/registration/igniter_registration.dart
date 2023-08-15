import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wazzlitt/src/event/edit_event_organizer.dart';
import 'package:wazzlitt/src/place/edit_place.dart';
import '../app.dart';

class IgniterRegistration extends StatefulWidget {
  const IgniterRegistration({super.key});

  @override
  State<IgniterRegistration> createState() => _IgniterRegistrationState();
}

class _IgniterRegistrationState extends State<IgniterRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.createIgniter,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.profileType,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditEventOrganizer())),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-1.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.eventOrganizer,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.eventOrganizerDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPlace())),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-2.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.businessOwner,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.businessOwnerDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                // onTap: () => Navigator.pushNamed(context, 'igniter_profile', arguments: 'individual'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-3.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.individual,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.individualDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
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