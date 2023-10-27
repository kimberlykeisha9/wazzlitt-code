import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/src/registration/interests.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/igniter_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

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
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Patrone()),
    ChangeNotifierProvider(create: (_) => Igniter()),
    ChangeNotifierProvider(create: (_) => BusinessOwner()),
    ChangeNotifierProvider(create: (_) => EventOrganizer()),
    ChangeNotifierProvider(create: (_) => DataSendingNotifier()),
  ], child: MyApp(settingsController: settingsController)));
}
