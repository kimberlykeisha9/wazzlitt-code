import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import 'package:image_picker/image_picker.dart';
import '../../authorization/authorization.dart';
import '../../user_data/patrone_data.dart';
import '../app.dart';

class PatroneRegistration extends StatefulWidget {
  const PatroneRegistration({super.key});

  @override
  State<PatroneRegistration> createState() => _PatroneRegistrationState();
}

class _PatroneRegistrationState extends State<PatroneRegistration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  DateTime? selectedDOB;
  String _selectedGender = 'male';

  // Local Images
  File? _profilePicture;

  // Images from Network
  String? networkProfile;

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profilePicture = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (!isLoggedIn()) {
      Navigator.popAndPushNamed(context, 'home');
    }
    Patrone().currentUserPatroneProfile.get().then((value) {
      if (value.exists) {
        setState(() {
          firstNameController = TextEditingController(
              text: Provider.of<Patrone>(context, listen: false).firstName);
          lastNameController = TextEditingController(
              text: Provider.of<Patrone>(context, listen: false).lastName);
          usernameController = TextEditingController(
              text: Provider.of<Patrone>(context, listen: false).username);
          emailController = TextEditingController(
              text: Provider.of<Patrone>(context, listen: false).emailAddress);
          dobController = TextEditingController(
              text: DateFormat.yMMMMd().format(
                  Provider.of<Patrone>(context, listen: false).dob ??
                      DateTime.now()));
          selectedDOB = Provider.of<Patrone>(context, listen: false).dob;
          _selectedGender =
              Provider.of<Patrone>(context, listen: false).gender ?? 'male';
          networkProfile =
              Provider.of<Patrone>(context, listen: false).profilePicture;
          passwordController = TextEditingController();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text(
                'Patrone Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.accountDetails,
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 100,
                width: width(context),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickProfilePicture(); // Function to handle profile picture selection
                      },
                      child: Center(
                        child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          shape: BoxShape.circle,
                          image: networkProfile != null
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(networkProfile!))
                              : _profilePicture == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(_profilePicture!)),
                        ),
                        child:
                            (_profilePicture != null || networkProfile != null)
                                ? const SizedBox()
                                : const Icon(Icons.person),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                flex: 15,
                child: SizedBox(
                  width: width(context),
                  height: height(context) * 0.5,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  return 'Last name is required';
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
                                labelText:
                                    AppLocalizations.of(context)!.username,
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
                                final emailRegex = RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)*[a-zA-Z]{2,7}$',
                                );
                                if (!(emailRegex.hasMatch(value))) {
                                  return 'Enter a valid email address';
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
                                  setState(() {
                                    selectedDOB = selectedDate;
                                  });
                                  dobController.text =
                                      DateFormat.yMMMd().format(selectedDate);
                                }
                              },
                              autofillHints: const [AutofillHints.birthday],
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const Text('Select your gender:'),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'non_binary',
                                child: Text('Non-binary'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'not_to_say',
                                child: Text('Prefer not to say'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'other',
                                child: Text('Other'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      try {
                        dataSendingNotifier.startLoading();
                        if (dataSendingNotifier.isLoading) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()));
                        }
                        uploadImageToFirebase(_profilePicture,
                                'users/${auth.currentUser!.uid}/patrone/profile_picture')
                            .then((profilePic) {
                            Patrone()
                                .saveUserPatroneInformation(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  username: usernameController.text,
                                  dob: selectedDOB,
                                  email: emailController.text,
                                  profilePic: profilePic,
                                  gender: _selectedGender,
                                )
                                .then(
                                    (value) => Navigator.popAndPushNamed(
                                        context, 'dashboard'),
                                    onError: (e) => showSnackbar(
                                        context,
                                        'An error has occured. '
                                        'Please try again later.'));
                          });
                        dataSendingNotifier.stopLoading();
                      } on Exception {
                        dataSendingNotifier.stopLoading();
                      }
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
