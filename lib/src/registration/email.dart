import 'package:flutter/material.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import 'package:wazzlitt/src/app.dart';

class EmailSignIn extends StatefulWidget {
  const EmailSignIn({super.key});

  @override
  State<EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  final TextEditingController emailController = TextEditingController(),
      confirmPasswordController = TextEditingController(),
      passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? doesEmailExist;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Enter your email address in the space below'),
                doesEmailExist == null ? const SizedBox(height: 20) : const SizedBox.shrink(),
                doesEmailExist == null ? TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  validator: (val) {
                    final RegExp emailRegex = RegExp(
                      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
                      caseSensitive: false,
                      multiLine: false,
                    );
                    if (val == null || val.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!(emailRegex.hasMatch(val))) {
                      return 'Please enter a valid email address';
                    }
                  },
                ) : const SizedBox.shrink(),
                doesEmailExist == null ? const SizedBox(height: 20) : const SizedBox.shrink(),
                doesEmailExist == null
                    ? ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            checkIfEmailExists(emailController.text)
                                .then((exists) {
                              setState(() {
                                doesEmailExist = exists;
                              });
                            });
                          }
                        },
                        child: const Text('Next'),
                      )
                    : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                doesEmailExist == null
                    ? const SizedBox.shrink()
                    : doesEmailExist!
                        ? RichText(
                            text: TextSpan(
                              text: 'Welcome Back, ',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              children: [
                                TextSpan(
                                    text: emailController.text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              text: 'Create your account for ',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              children: [
                                TextSpan(
                                    text: emailController.text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                doesEmailExist != null
                    ? TextButton(
                        child:
                            const Text('Wrong email account? Change email address'),
                        onPressed: () {
                          setState(() {
                            doesEmailExist = null;
                          });
                        })
                    : const SizedBox.shrink(),
                    const SizedBox(height: 20),
                doesEmailExist != null
                    ? TextFormField(
                        controller: passwordController,
                        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password cannot be empty';
          }
          return null; // Return null if the input is valid
        },
                        decoration: const InputDecoration(
                          labelText: 'Enter your password',
                        ),
                      )
                    : const SizedBox.shrink(),
                doesEmailExist == null
                    ? const SizedBox.shrink()
                    : doesEmailExist!
                        ? const SizedBox.shrink()
                        : TextFormField(
                            controller: confirmPasswordController,
                            validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password confirmation cannot be empty';
          }
          if (value != passwordController.text) {
            return 'Passwords do not match';
          }
          return null; // Return null if the input is valid
        },
                            decoration: const InputDecoration(
                              labelText: 'Confirm your password',
                            ),
                          ),
                          const SizedBox(height: 20),
                doesEmailExist == null
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: () {
                          if (doesEmailExist!) {
                            signInWithEmailPassword(emailController.text,
                                    passwordController.text, context)
                                .then((value) {
                              if (isLoggedIn()) {
                                Navigator.popAndPushNamed(context, 'dashboard');
                              } else {
                                showSnackbar(context,
                                    'An error has occured. Please try again later');
                              }
                            });
                          } else {
                            signUpWithEmailPasswordAndLinkGoogle(
                                    emailController.text,
                                    passwordController.text,
                                    context)
                                .then((value) {
                              if (isLoggedIn()) {
                                Navigator.popAndPushNamed(context, 'dashboard');
                              } else {
                                showSnackbar(context,
                                    'An error has occured. Please try again later');
                              }
                            });
                          }
                        },
                        child: Text(
                            doesEmailExist! ? 'Sign In' : 'Create Account')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
