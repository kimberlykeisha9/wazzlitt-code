import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../registration/interests.dart';

class IgniterProfile extends StatefulWidget {
  const IgniterProfile({super.key});

  @override
  State<IgniterProfile> createState() => _IgniterProfileState();
}

class _IgniterProfileState extends State<IgniterProfile> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  String? networkProfile;
  String? networkCoverPhoto;

  final List<String> dropdownOptions = [
    'Restaurant',
    'Club',
    'Bar',
    'Lounge',
    'Outdoor',
    'Family Friendly',
  ];
  String? selectedOption;

  File? _coverPhoto;
  File? _profilePicture;
  String? _selectedChip;
  String? igniterType = '';

  List<Category> categories = [];

  @override
  void initState() {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
        setState(() {
          igniterType = ModalRoute.of(context)!.settings.arguments as String;
          print(igniterType);
        });
      });
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _websiteController = TextEditingController();
    _descriptionController = TextEditingController();
    _emailController = TextEditingController();
    _locationController = TextEditingController();
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
        setState(() {
          igniterType = ModalRoute.of(context)!.settings.arguments as String;
          print(igniterType);
        });
      });
      currentUserIgniterProfile.get().then((igniterData) => {
      _nameController.text = igniterData?['title'],
          _phoneController.text = igniterData?['phone_number'],
          _websiteController.text = igniterData?['website'],
          _locationController.text = igniterData?['location'],
          _descriptionController.text = igniterData?['description'],
          _emailController.text = igniterData?['email_address'],
          _selectedChip = igniterData?['category'],
          selectedOption = igniterData?['business_type'],
        networkCoverPhoto = igniterData?['cover_photo'],
        networkProfile = igniterData?['profile_photo'],

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

  Future<void> _downloadAndSaveImage(String? imageUrl, File? toBeSet) async {
    try {
      if(imageUrl == null) {
        return;
      } else {

        http.Response response = await http.get(Uri.parse(imageUrl!));

      if (response.statusCode == 200) {
        final picker = ImagePicker();
        final image = File.fromRawPath(response.bodyBytes);

        setState(() {
          toBeSet = image;
        });
      } else {
        print('Failed to download image: ${response.statusCode}');
      }}
    } catch (e) {
      print('Error downloading image: $e');
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
          Map<String, dynamic>? igniterData = snapshot.data?.data() as Map<String, dynamic>?;
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
                            image: igniterData?['cover_photo'] != null ? DecorationImage(
                              image: NetworkImage(igniterData!['cover_photo'])
                            ) : _coverPhoto == null ? null : DecorationImage(image: FileImage(_coverPhoto!)),
                          ),
                          child: _coverPhoto != null
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
                              image: igniterData?['profile_photo'] != null ? DecorationImage(
                                  image: NetworkImage(igniterData!['profile_photo'])
                              ) : _profilePicture == null ? null : DecorationImage(image: FileImage(_profilePicture!)),
                            ),
                            child: _profilePicture != null
                                ? SizedBox()
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
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Business name is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.name),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                          ),
                          igniterType == 'business_owner' ? const Padding(padding: EdgeInsets.only(top: 15)) : SizedBox(),
                          igniterType == 'business_owner' ? Container(
                        width: width(context),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: SizedBox(),
                          hint: Text('Select your business type'),
                          value: selectedOption,
                          onChanged: (newValue) {
                            setState(() {
                              selectedOption = newValue;
                            });
                            // Perform any desired action when the option is selected
                            print(selectedOption);
                          },
                          items: dropdownOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                        ),
                      ) : const SizedBox(),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          Text(AppLocalizations.of(context)!.selectCategory,
                              style: const TextStyle(fontSize: 12)),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories
                                  .map(
                                    (chip) => Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 5),
                                      child: ChoiceChip(
                                        label: Text(chip.display),
                                        selected: _selectedChip == chip.display,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedChip = selected ? chip
                                                .display : '';
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          IntlPhoneField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.phone,
                                ),
                            keyboardType: TextInputType.number,
                            onChanged: (phone) {
                              storeData('phone', phone.completeNumber);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Phone number is required';
                              }
                              return null; // Return null if the input is valid
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          TextFormField(
                            controller: _websiteController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Website is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.website),
                            keyboardType: TextInputType.url,
                          ),
                          igniterType == 'business_owner' ? const Padding(padding: EdgeInsets.only(top: 15)) : SizedBox(),
                          igniterType == 'business_owner' ? TextFormField(
                            controller: _locationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Location is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: 'Location'),
                            keyboardType: TextInputType.streetAddress,
                          ) : SizedBox(),
                          const Padding(padding: EdgeInsets.only(top: 15)),
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
                                labelText:
                                    AppLocalizations.of(context)!.description),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          TextFormField(
                            controller: _emailController,
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
                                labelText: AppLocalizations.of(context)!.email),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: width(context) * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_profilePicture != null && _coverPhoto != null) {
                        if (selectedOption != null) {
                          if (_selectedChip != null) {
                            if (_formKey.currentState!.validate()) {
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
                                      onPressed: () => {
                                        savePlaceProfile(
                                          businessName: _nameController.text, location: _locationController.text, website: _websiteController.text,
                                          category: _selectedChip, description: _descriptionController.text, emailAddress: _emailController.text,
                                          phoneNumber: _phoneController.text,).then((value) => Navigator.popAndPushNamed(context, 'igniter_dashboard')),
                                      },
                                      child:
                                          Text(AppLocalizations.of(context)!.proceed),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            showSnackbar(context, 'Please select a category');
                          }
                        }
                        else {
                          showSnackbar(context, 'Please select a business type');
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
      ),
    );
  }
}
