import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.privacyInfo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.profileVisibility),
                        DropdownButton<String>(
                          value: 'Public',
                          onChanged: (String? value) {
                            if (value == 'Public') {
                              // Handle Public option
                            } else if (value == 'Private') {
                              // Handle Private option
                            }
                          },
                          items: <String>[
                            'Public',
                            'Private',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.allowMessages),
                        DropdownButton<String>(
                          value: 'Everyone',
                          onChanged: (String? value) {
                            if (value == 'Everyone') {
                              // Handle Public option
                            } else if (value == 'Followers') {
                              // Handle Private option
                            } else if (value == 'Followers I follow back') {
                              // Handle
                            }
                          },
                          items: <String>[
                            'Everyone',
                            'Followers',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.blocked),
                      const Text('0'),
                    ],
                  ),
                  Text(AppLocalizations.of(context)!.dataUsage),
                  const Text('Notification Settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Push Notifications'),
                  const Text('Email Notifications'),
                  const Text('SMS Notifications'),
                  const Text('Language and Localizations',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Language'),
                  const Text('Date format'),
                  const Text('Currency'),
                  const Text('Connected Accounts',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Facebook'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Twitter'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Instagram'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Email'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  const Text('Help and Support',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('FAQ and Help Centre'),
                  const Text('Contact Support'),
                  const Text('About and Legal Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('App Version'),
                      Text('1.0.0'),
                    ],
                  ),
                  const Text('Terms of Service'),
                ],
              ),
            ),
          ),
        ));
  }
}
