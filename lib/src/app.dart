import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazzlitt/src/dashboard/dashboard.dart';
import '../authorization/authorization.dart';
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
class MyApp extends StatefulWidget {
  MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override 
  void initState() {
    super.initState();
    auth.currentUser?.reload();
  }
  final bool isLoggedIn = auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.settingsController,
        builder: (BuildContext context, Widget? child) {
          return Center(
            child: MaterialApp(
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
              darkTheme: darkTheme(context).copyWith(textTheme: GoogleFonts.interTextTheme(darkTheme(context).textTheme)),
              theme: ThemeData(
                  tabBarTheme:
                      TabBarTheme(labelColor: Colors.yellow[700]!),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      backgroundColor: Colors.yellow[700]!),
                  appBarTheme: AppBarTheme(
                    color: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    titleTextStyle:
                        const TextStyle(color: Colors.black, fontSize: 16),
                    toolbarHeight: height(context) * 0.075,
                    iconTheme: IconThemeData(color: Colors.yellow[700]!),
                  ),
                  chipTheme: ChipThemeData(
                      backgroundColor: Colors.indigo,
                      selectedColor: Colors.indigo[800]),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)))),
                  colorScheme: ColorScheme.light(
                      primary: Colors.yellow[700]!,
                      onPrimary: Colors.amber[900]!,
                      secondary: Colors.indigo)),
              themeMode: widget.settingsController.themeMode,
              initialRoute: isLoggedIn ? 'dashboard' : 'home',
              routes: {
                'home': (context) => const Home(),
                'signup': (context) => SignUp(),
                'patrone_registration': (context) =>
                    const PatroneRegistration(),
                'interests': (context) => const Interests(),
                'igniter_registration': (context) =>
                    const IgniterRegistration(),
                'patrone_dashboard': (context) => const PatroneDashboard(),
                'settings': (context) => const Settings(),
                'orders': (context) => const Orders(),
                'confirmed': (context) => const ConfirmedOrder(),
                'dashboard': (context) => Dashboard(),
                'igniter_dashboard': (context) => const IgniterDashboard(),
              },
            ),
          );
        },
      
    );
  }

  ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                  onPrimary: Colors.white,
                  primary: Colors.yellow[700]!,
                  secondary: Colors.indigo),
              chipTheme: ChipThemeData(
                  backgroundColor: Colors.indigo,
                  selectedColor: Colors.indigo[800]),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)),
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
                      padding: const EdgeInsets.all(20),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
              textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
              )),
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

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}

