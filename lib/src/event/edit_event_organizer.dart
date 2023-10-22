import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../../user_data/event_organizer_data.dart';
import '../app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../registration/interests.dart';

class EditEventOrganizer extends StatefulWidget {
  const EditEventOrganizer({super.key});

  @override
  State<EditEventOrganizer> createState() => _EditEventOrganizerState();
}

class _EditEventOrganizerState extends State<EditEventOrganizer> {
  // Form Controller
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Images from Network
  String? networkProfile;
  // Local Images
  var _profilePicture;

  // Selected Category
  String? _selectedChip;

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    // Fill in the text controller values
    WidgetsFlutterBinding.ensureInitialized();
    currentUserIgniterProfile.get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? organizerData = value.data();
        _nameController.text = organizerData?['organizer_name'] ?? '';
        _phoneController.text = organizerData?['phone_number'] ?? '';
        _websiteController.text = organizerData?['website'] ?? '';
        _descriptionController.text =
            organizerData?['organizer_description'] ?? '';
        _emailController.text = organizerData?['email_address'] ?? '';
        networkProfile = organizerData?['image'];
        _selectedChip = organizerData?['category'];
      }
    });
    firestore.collection('app_data').doc('categories').get().then((value) {
      var data = value.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        var itemData = value as Map<String, dynamic>;
        String display = itemData['display'];
        String image = itemData['image'];
        setState(() {
          Category category = Category(display, image);
          categories.add(category);
        });
      });
    });
  }

  late final Future<DocumentSnapshot> getIgniterInfo =
      currentUserIgniterProfile.get();

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Igniter Profile'),
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: getIgniterInfo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: width(context),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              selectImage().then((value) {
                                setState(() {
                                  _profilePicture = value;
                                });
                              }); // Function to handle profile picture selection
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
                                        image: NetworkImage(networkProfile!))
                                    : _profilePicture == null
                                        ? null
                                        : kIsWeb
                                            ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: MemoryImage(
                                                    _profilePicture!))
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
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: height(context) * 0.5,
                          width: width(context),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Organizer name is required';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context)!.name),
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .selectCategory,
                                      style: const TextStyle(fontSize: 12)),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: categories
                                          .map(
                                            (chip) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: ChoiceChip(
                                                label: Text(chip.display),
                                                selected: _selectedChip ==
                                                    chip.display /*  ||
                                                    organizerData?['category'] ==
                                                        chip.display */
                                                ,
                                                onSelected: (selected) {
                                                  setState(() {
                                                    _selectedChip = selected
                                                        ? chip.display
                                                        : '';
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  IntlPhoneField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.phone,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Phone number is required';
                                      }
                                      return null; // Return null if the input is valid
                                    },
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  TextFormField(
                                    controller: _websiteController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {}
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .website),
                                    keyboardType: TextInputType.url,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  TextFormField(
                                    controller: _descriptionController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Description is required';
                                      }
                                      return null;
                                    },
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .description),
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  TextFormField(
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {}
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value!)) {
                                        return 'Invalid email address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .email),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width(context) * 0.8,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_selectedChip != null) {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  dataSendingNotifier.startLoading();
                                  if (dataSendingNotifier.isLoading) {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => const Center(
                                            child:
                                                CircularProgressIndicator()));
                                  }
                                  uploadImageToFirebase(_profilePicture,
                                          'users/${auth.currentUser!.uid}/igniter/profile_photo')
                                      .then((profilePic) {
                                    EventOrganizer()
                                        .saveEventOrganizerProfile(
                                          organizerName: _nameController.text,
                                          website: _websiteController.text,
                                          category: _selectedChip,
                                          description:
                                              _descriptionController.text,
                                          emailAddress: _emailController.text,
                                          phoneNumber: _phoneController.text,
                                          profilePhoto:
                                              profilePic ?? networkProfile,
                                        )
                                        .then((value) =>
                                            Navigator.popAndPushNamed(
                                                context, 'dashboard'));
                                  });
                                  dataSendingNotifier.stopLoading();
                                } on Exception {
                                  dataSendingNotifier.stopLoading();
                                }
                              }
                            } else {
                              showSnackbar(context, 'Please select a category');
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
