import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazzlitt/src/dashboard/dashboard.dart';
import '../authorization/authorization.dart';
import 'dashboard/feed.dart';
import 'dashboard/igniter_dashboard.dart';
import 'dashboard/patrone_dashboard.dart';
import 'orders/confirmed_order.dart';
import 'orders/orders.dart';
import 'registration/home.dart';
import 'registration/igniter_registration.dart';
import 'registration/patrone_registration.dart';
import 'registration/interests.dart';
import 'settings/settings.dart';
import 'settings/settings_controller.dart';
import 'registration/sign_up.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required this.settingsController,
  });

  final bool isLoggedIn = auth.currentUser != null;

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<Data>(create: (_) => Data()),
    ],
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            darkTheme: ThemeData(
                colorScheme: ColorScheme.dark(
                  onPrimary: Colors.white,
                    primary: Colors.orangeAccent[700]!,
                    secondary: Colors.indigo),
              chipTheme: ChipThemeData(
                  backgroundColor: Colors.indigo,
                  selectedColor: Colors.indigo[800]),
              inputDecorationTheme: InputDecorationTheme(
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              appBarTheme: AppBarTheme(
                color: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle:
                const TextStyle(color: Colors.white, fontSize: 16),
                toolbarHeight: height(context) * 0.075,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo,
                )
              ),
              textTheme: const TextTheme(
                labelLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 16),
              ),
            ),
            theme: ThemeData(
                tabBarTheme: TabBarTheme(labelColor: Colors.orangeAccent[700]),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Colors.orangeAccent[700]),
                appBarTheme: AppBarTheme(
                  color: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle:
                      const TextStyle(color: Colors.black, fontSize: 16),
                  toolbarHeight: height(context) * 0.075,
                  iconTheme: IconThemeData(color: Colors.orangeAccent[700]),
                ),
                chipTheme: ChipThemeData(
                    backgroundColor: Colors.indigo,
                    selectedColor: Colors.indigo[800]),
                inputDecorationTheme: InputDecorationTheme(
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                textTheme: const TextTheme(
                  labelLarge: TextStyle(fontSize: 16),
                  bodyMedium: TextStyle(fontSize: 16),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                colorScheme: ColorScheme.light(
                    primary: Colors.orangeAccent[700]!,
                    secondary: Colors.indigo)),
            themeMode: settingsController.themeMode,
            initialRoute: isLoggedIn ? 'dashboard' : 'home',
            routes: {
              'home': (context) => const Home(),
              'signup': (context) => SignUp(),
              'patrone_registration': (context) => const PatroneRegistration(),
              'interests': (context) => const Interests(),
              'igniter_registration': (context) => const IgniterRegistration(),
              'patrone_dashboard': (context) => const PatroneDashboard(),
              'settings': (context) => const Settings(),
              'orders': (context) => const Orders(),
              'confirmed': (context) => const ConfirmedOrder(),
              'dashboard': (context) => const Dashboard(),
              'igniter_dashboard': (context) => const IgniterDashboard(),
              // 'place_order': (context) => PlaceOrder(),
            },
          );
        },
      ),
    );
  }
}

Future<bool> storeData(String key, String value) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  log('Stored');
  return pref.setString(key, value);
}

Future<String?> getData(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? val = pref.getString(key);
  log(val ?? 'Nothing there');
  return val;
}

enum OrderType { event, service }

enum ChatRoomType { individual, business }

class Chat {
  final String senderName;
  final String senderImage;
  final ChatRoomType chatType;
  final List<Message> messages;

  Chat({
    required this.senderName,
    required this.senderImage,
    required this.messages,
    required this.chatType,
  });
}

class Message {
  final String senderName;
  final String content;
  final String time;

  Message({
    required this.senderName,
    required this.content,
    required this.time,
  });
}

// Sample chat data
final List<Chat> chatData = [
  Chat(
    senderName: 'John Doe',
    senderImage: 'assets/images/john_doe_avatar.jpg',
    chatType: ChatRoomType.individual,
    messages: [
      Message(
        senderName: 'John Doe',
        content: 'Hello, how are you?',
        time: '10:30 AM',
      ),
      Message(
        senderName: 'You',
        content: 'I\'m good, thanks! How about you?',
        time: '10:35 AM',
      ),
    ],
  ),
  Chat(
    senderName: 'Jane Smith',
    senderImage: 'assets/images/jane_smith_avatar.jpg',
    chatType: ChatRoomType.individual,
    messages: [
      Message(
        senderName: 'Jane Smith',
        content: 'I will be there soon.',
        time: '9:45 AM',
      ),
      Message(
        senderName: 'You',
        content: 'Great, see you soon!',
        time: '9:50 AM',
      ),
    ],
  ),
  Chat(
    senderName: 'David Johnson',
    chatType: ChatRoomType.individual,
    senderImage: 'assets/images/david_johnson_avatar.jpg',
    messages: [
      Message(
        senderName: 'You',
        content: 'Can you please send me the document?',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'David Johnson',
        content: 'Sure, I will send it to you shortly.',
        time: 'Yesterday',
      ),
    ],
  ),
  Chat(
    senderName: 'Business',
    chatType: ChatRoomType.business,
    senderImage: 'assets/images/david_johnson_avatar.jpg',
    messages: [
      Message(
        senderName: 'You',
        content: 'How is everything going',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'David Johnson',
        content: 'Everything is cool over here',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'Moses Mbuva',
        content: 'Want to go grab a drink?',
        time: 'Yesterday',
      ),
    ],
  ),
];

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

// List<String> categories = ['Ratchet', 'Free Spirit', 'Classy', 'Rock', 'Afro'];

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}
