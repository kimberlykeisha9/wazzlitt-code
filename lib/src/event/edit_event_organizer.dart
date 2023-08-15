import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../registration/interests.dart';

class EditEventOrganizer extends StatefulWidget {
  const EditEventOrganizer({super.key});

  @override
  State<EditEventOrganizer> createState() => _EditEventOrganizerState();
}

class _EditEventOrganizerState extends State<EditEventOrganizer>
    with AutomaticKeepAliveClientMixin<EditEventOrganizer> {
  @override
  bool get wantKeepAlive => true;

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
  String? networkCoverPhoto;
  // Local Images
  File? _coverPhoto;
  File? _profilePicture;

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
        Map<String, dynamic>? organizerData =
        value.data();
        _nameController.text = organizerData?['organizer_name'] ?? '';
        _phoneController.text = organizerData?['phone_number'] ?? '';
        _websiteController.text = organizerData?['website'] ?? '';
        _descriptionController.text = organizerData?['organizer_description'] ?? '';
        _emailController.text = organizerData?['email_address'] ?? '';
        networkCoverPhoto = organizerData?['cover_image'] ?? '';
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Igniter Profile'),
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: currentUserIgniterProfile.get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? organizerData =
                snapshot.data?.data() as Map<String, dynamic>?;
                return SafeArea(
                  child: Column(
                    children: [
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
                                    textCapitalization: TextCapitalization.words,
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
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: ChoiceChip(
                                                label: Text(chip.display),
                                                selected: _selectedChip ==
                                                        chip.display /*  ||
                                                    organizerData?['category'] ==
                                                        chip.display */,
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
                                      if (value == null || value.isEmpty) {
                                        return 'Website is required';
                                      }
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
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Invalid email address';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context)!.email),
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
                          onPressed: () {
                            if ((_profilePicture != null &&
                                _coverPhoto != null) || (networkProfile != null &&  networkCoverPhoto != null)) {
                              if (_selectedChip != null) {
                                if (_formKey.currentState!.validate()) {
                                  if (organizerData == null) {
                                    paymentPrompt(context);
                                  } else {
                                    uploadImageToFirebase(_coverPhoto,
                                            'users/${auth.currentUser!.uid}/igniter/cover_photo')
                                        .then((coverPic) {
                                      uploadImageToFirebase(_profilePicture,
                                              'users/${auth.currentUser!.uid}/igniter/profile_photo')
                                          .then((profilePic) {
                                        saveEventOrganizerProfile(
                                          organizerName: _nameController.text,
                                          website: _websiteController.text,
                                          category: _selectedChip,
                                          description: _descriptionController.text,
                                          emailAddress: _emailController.text,
                                          phoneNumber: _phoneController.text,
                                          coverPhoto:
                                              coverPic ?? networkCoverPhoto,
                                          profilePhoto:
                                              profilePic ?? networkProfile,
                                        ).then((value) =>
                                            Navigator.pushReplacementNamed(
                                                context, 'igniter_dashboard'));
                                      });
                                    });
                                  }
                                }
                              } else {
                                showSnackbar(
                                    context, 'Please select a category');
                              }
                            } else {
                              showSnackbar(context,
                                  'Please upload a profile picture and cover image');
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

  void paymentPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.createIgniter,
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppLocalizations.of(context)!.igniterTrial,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              uploadImageToFirebase(_coverPhoto,
                      'users/${auth.currentUser!.uid}/igniter/cover_photo')
                  .then((coverPic) {
                uploadImageToFirebase(_profilePicture,
                        'users/${auth.currentUser!.uid}/igniter/profile_photo')
                    .then((profilePic) {
                  saveEventOrganizerProfile(
                    organizerName: _nameController.text,
                    website: _websiteController.text,
                    category: _selectedChip,
                    description: _descriptionController.text,
                    emailAddress: _emailController.text,
                    phoneNumber: _phoneController.text,
                    coverPhoto: coverPic ?? networkCoverPhoto,
                    profilePhoto: profilePic ?? networkProfile,
                  ).then((value) => Navigator.pushReplacementNamed(
                      context, 'igniter_dashboard'));
                });
              });
            },
            child: Text(AppLocalizations.of(context)!.proceed),
          ),
        ],
      ),
    );
  }
}
