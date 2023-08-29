import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/registration/interests.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import '../../user_data/patrone_data.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Initializing firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  Stripe.publishableKey = 'pk_test_51N6MV7Aw4gbUiKSO9S7epyOYDxLjQxzQjUUP4cwPaTpMAIFX6cccpePl4vlPyBDQLL3uKycqBaVKRDD0LoteysiN00pGKIfRjG';
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Patrone()),
      ],
      child: MyApp(settingsController: settingsController)));
}
