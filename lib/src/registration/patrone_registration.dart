import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import 'package:image_picker/image_picker.dart';
import '../../authorization/authorization.dart';
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
  bool? _isGangMember = false;
  bool? _isHIVPositive = false;
  String _selectedGender = 'male';

  // Local Images
  File? _coverPhoto;
  File? _profilePicture;
  // Images from Network
  String? networkProfile;
  String? networkCoverPhoto;

  bool _isExistingUser = false;

  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _coverPhoto = File(pickedImage.path);
      });
    }
  }

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
    currentUserPatroneProfile.get().then((profile) {
      if (profile.exists) {
        Map<String, dynamic>? data = profile.data();
        setState(() {
          firstNameController = TextEditingController(text: data?['first_name']);
          lastNameController = TextEditingController(text: data?['last_name']);
          usernameController = TextEditingController(text: auth.currentUser!.displayName);
          emailController = TextEditingController(text: auth.currentUser!.email);
          dobController = TextEditingController(text: DateFormat.yMMMMd().format((data?['dob'] as Timestamp).toDate()));
          selectedDOB = (data?['dob'] as Timestamp).toDate();
          _selectedGender = data!['gender'];
          networkProfile = data!['profile_picture'];
          networkCoverPhoto = data!['cover_photo'];
          _isHIVPositive = data!['is_hiv_positive'];
          _isGangMember = data!['is_gang_member'];
          passwordController = TextEditingController();
          _isExistingUser = true;
        });
      }
    });

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
                'Patrone Account',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.accountDetails,
              ),
              const Spacer(),
              SizedBox(
                height: 200,
                width: width(context),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickCoverPhoto(); // Function to handle cover photo selection
                      },
                      child: Container(
                        width: width(context),
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          image: networkCoverPhoto != null
                              ? DecorationImage(
                              fit: BoxFit.cover,
                              image:
                              NetworkImage(networkCoverPhoto!))
                              : _coverPhoto == null
                              ? null
                              : DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(_coverPhoto!)),
                        ),
                        child: (_coverPhoto != null ||
                            networkCoverPhoto != null)
                            ? const SizedBox()
                            : const Icon(Icons.add_photo_alternate),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          _pickProfilePicture(); // Function to handle profile picture selection
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            shape: BoxShape.circle,
                            image: networkProfile != null
                                ? DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                NetworkImage(networkProfile!))
                                : _profilePicture == null
                                ? null
                                : DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(
                                    _profilePicture!)),
                          ),
                          child: (_profilePicture != null ||
                              networkProfile != null)
                              ? const SizedBox()
                              : const Icon(Icons.person),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                                labelText: AppLocalizations.of(context)!.username,
                              ),
                              autofillHints: const [AutofillHints.newUsername],
                              keyboardType: TextInputType.name,
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
                                  dobController.text = DateFormat.yMMMd().format(selectedDate);
                                }
                              },
                              autofillHints: const [AutofillHints.birthday],
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          Text('Select your gender:'),
                          SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            items: [
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
                          CheckboxListTile(
                            title: Text('Are you a gang member?'),
                            value: _isGangMember,
                            onChanged: (value) {
                              setState(() {
                                _isGangMember = value!;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: Text('Are you HIV positive?'),
                            value: _isHIVPositive,
                            onChanged: (value) {
                              setState(() {
                                _isHIVPositive = value!;
                              });
                            },
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  child: Text('Continue'),
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
                              onPressed: () => saveUserPatroneInformation(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                username: usernameController.text,
                                dob: selectedDOB,
                                isGangMember: _isGangMember,
                                isHIVPositive: _isHIVPositive,
                                gender: _selectedGender,
                              ).then((value) => Navigator.popAndPushNamed(
                                  context, 'interests'), onError: (e) =>
                              showSnackbar(context, 'An error has occured. '
                                  'Please try again later.')),
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
