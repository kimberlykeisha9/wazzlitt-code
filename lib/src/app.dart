import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
          theme: ThemeData(
              appBarTheme: AppBarTheme(
                color: Colors.transparent,
                elevation: 0,
                toolbarHeight: height(context) * 0.1,
                iconTheme: IconThemeData(color: Colors.indigo[900]!),
              ),
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
                  primary: Colors.indigo[900]!,
                  secondary: Colors.greenAccent[400]!)),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: 'home',
          routes: {
            'home': (context) => const Home(),
            'signup': (context) => const SignUp(),
            'patrone_registration': (context) => PatroneRegistration(),
            'interests': (context) => const Interests(),
          },
        );
      },
    );
  }
}

class Interests extends StatelessWidget {
  const Interests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.chooseInterests,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Text(AppLocalizations.of(context)!.interestsSubtitle,
                  textAlign: TextAlign.center),
              const Spacer(),
              SizedBox(
                width: width(context),
                height: height(context) * 0.5,
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per column
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    bool isChecked;
                    isChecked = true;
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/igniter-1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 20,
                                color: isChecked ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context)!.proceed)))
            ],
          ),
        ),
      ),
    );
  }
}

List<String> categories = ['Ratchet', 'Free Spirit', 'Classy', 'Rock', 'Afro'];

class PatroneRegistration extends StatelessWidget {
  PatroneRegistration({super.key});
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.createPatrone,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.accountDetails,
              ),
              const Spacer(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.fname,
                        ),
                        autofillHints: const [AutofillHints.name],
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const Spacer(),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.lname,
                        ),
                        autofillHints: const [AutofillHints.name],
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const Spacer(),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.username,
                        ),
                        autofillHints: const [AutofillHints.newUsername],
                        keyboardType: TextInputType.name,
                      ),
                      const Spacer(),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                        ),
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const Spacer(),
                      TextFormField(
                        controller: dobController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.dob,
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            dobController.text = selectedDate
                                .toString(); // Update the text controller with selected date
                          }
                        },
                        autofillHints: const [AutofillHints.birthday],
                        keyboardType: TextInputType.datetime,
                      ),
                      const Spacer(),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.create),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.createPatrone,
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.patroneTrial,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.popAndPushNamed(context, 'interests'),
                          child: Text(AppLocalizations.of(context)!.proceed),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUp extends StatelessWidget {
  const SignUp({super.key});

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
                    onPressed: () =>
                        Navigator.pushNamed(context, 'patrone_registration'),
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
            Text(
              AppLocalizations.of(context)!.homeTitle,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: width(context),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'signup'),
                child: Text(
                  AppLocalizations.of(context)!.patrone,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: width(context),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'signup'),
                child: Text(
                  AppLocalizations.of(context)!.igniter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}
