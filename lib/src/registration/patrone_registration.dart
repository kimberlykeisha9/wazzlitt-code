import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../app.dart';

class PatroneRegistration extends StatefulWidget {
  const PatroneRegistration({super.key});

  @override
  State<PatroneRegistration> createState() => _PatroneRegistrationState();
}

class _PatroneRegistrationState extends State<PatroneRegistration> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController();
    passwordController = TextEditingController();
  }

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
              Expanded(
                flex: 12,
                child: SizedBox(
                  width: width(context),
                  height: height(context) * 0.5,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 15),
                          child: TextFormField(
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              if (value.length < 3) {
                                return 'Enter a valid last name';
                              }
                              if (!RegExp(r'([a-z]+)', caseSensitive: false)
                                  .hasMatch(value)) {
                                return 'Invalid characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.fname,
                            ),
                            autofillHints: const [AutofillHints.name],
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              if (value.length < 3) {
                                return 'Enter a valid last name';
                              }
                              if (!RegExp(r'([a-z]+)', caseSensitive: false)
                                  .hasMatch(value)) {
                                return 'Invalid characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.lname,
                            ),
                            autofillHints: const [AutofillHints.name],
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              // Define the username pattern (example: only allow lowercase letters and digits, 4-10 characters)
                              // const usernamePattern = r'^[a-z0-9]$';
                              // final regex = RegExp(usernamePattern);
                              // if (!regex.hasMatch(value)) {
                              //   return 'Invalid username. Do not use capital letters or symbols';
                              // }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.username,
                            ),
                            autofillHints: const [AutofillHints.newUsername],
                            keyboardType: TextInputType.name,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.email,
                            ),
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: dobController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              return null;
                            },
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
                                dobController.text = DateFormat.yMMMd().format(selectedDate);
                              }
                            },
                            autofillHints: const [AutofillHints.birthday],
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (!RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                  .hasMatch(value)) {
                                return 'Password must contain at least 8 characters, one capital letter, one number, and one symbol';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                            ),
                            autofillHints: const [AutofillHints.newPassword],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.create),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
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
                              onPressed: () => Navigator.popAndPushNamed(
                                  context, 'interests'),
                              child:
                                  Text(AppLocalizations.of(context)!.proceed),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
