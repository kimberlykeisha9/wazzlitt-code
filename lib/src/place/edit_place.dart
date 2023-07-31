import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../registration/interests.dart';

class EditPlace extends StatefulWidget {
  const EditPlace({super.key, this.place});
  final DocumentReference? place;

  @override
  State<EditPlace> createState() => _EditPlaceState();
}

class _EditPlaceState extends State<EditPlace> {
  // Form Controller
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  String? _name;
  String? _phone;
  String? _website;
  String? _description;
  String? _email;
  String? _location;
  String? _openingTimeText;
  String? _closingTimeText;

  // Time
  Timestamp? _openingTime;
  Timestamp? _closingTime;

  // Images from Network
  String? networkProfile;
  String? networkCoverPhoto;
  // Local Images
  File? _coverPhoto;
  File? _profilePicture;

  // Establishment Type
  final List<String> dropdownOptions = [
    'Restaurant',
    'Club',
    'Bar',
    'Lounge',
    'Outdoor',
    'Family Friendly',
  ];
  String? selectedOption; // Selected Establishment Type

  // Selected Category
  String? _selectedChip;

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    // Fill in the text controller values
    WidgetsFlutterBinding.ensureInitialized();
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
            future: widget.place?.get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? placeData;
                if (widget.place != null) {
                  widget.place!.get().then((data) {
                    placeData = data.data() as Map<String, dynamic>?;
                    setState(() {
                      _name = placeData?['place_name'];
                      _phone = placeData?['phone_number'];
                      _website = placeData?['website'];
                      _location = placeData?['location'];
                      _description = placeData?['place_description'];
                      _email = placeData?['email_address'];
                      networkCoverPhoto = placeData?['cover_image'];
                      networkProfile = placeData?['image'];
                      _openingTime = placeData?['opening_time'];
                      _closingTime = placeData?['closing_time'];
                      _openingTime != null
                          ? _openingTimeText =
                              DateFormat.Hm().format(_openingTime!.toDate())
                          : null;
                      _closingTime != null
                          ? _closingTimeText =
                              DateFormat.Hm().format(_closingTime!.toDate())
                          : null;
                    });
                  });
                }
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
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                TextFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _name = val;
                                    });
                                  },
                                  initialValue: _name,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Business name is required';
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
                                Container(
                                  width: width(context),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    hint: const Text('Select your business type'),
                                    value:  placeData?['place_type'] ?? selectedOption,
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
                                ),
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
                                              selected:
                                              _selectedChip == chip.display || placeData?['category'] == chip.display,
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
                                Row(children: [
                                  Expanded(
                                    flex: 8,
                                    child: TextFormField(
                                        onChanged: (val) {
                                          setState(() {
                                            _openingTimeText = DateFormat.Hm()
                                                .format(_openingTime!.toDate());
                                          });
                                        },
                                        initialValue: _openingTimeText,
                                        readOnly: true,
                                        onTap: () => showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        const TimeOfDay(
                                                            hour: 0, minute: 0))
                                                .then(
                                              (pickedTime) {
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    _openingTime =
                                                        Timestamp.fromDate(
                                                            DateTime(
                                                                2000,
                                                                1,
                                                                1,
                                                                pickedTime.hour,
                                                                pickedTime
                                                                    .minute));
                                                    _openingTimeText =
                                                        DateFormat.Hm().format(
                                                            _openingTime!
                                                                .toDate());
                                                  });
                                                }
                                              },
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Opening Time',
                                        )),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    flex: 8,
                                    child: TextFormField(
                                        onChanged: (val) {
                                          setState(() {
                                            _closingTimeText = DateFormat.Hm()
                                                .format(_closingTime!.toDate());
                                          });
                                        },
                                        initialValue: _closingTimeText,
                                        readOnly: true,
                                        onTap: () => showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        const TimeOfDay(
                                                            hour: 0, minute: 0))
                                                .then(
                                              (pickedTime) {
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    _closingTime =
                                                        Timestamp.fromDate(
                                                            DateTime(
                                                                2000,
                                                                1,
                                                                1,
                                                                pickedTime.hour,
                                                                pickedTime
                                                                    .minute));
                                                    _closingTimeText =
                                                        DateFormat.Hm().format(
                                                            _closingTime!
                                                                .toDate());
                                                  });
                                                }
                                              },
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Closing Time',
                                        )),
                                  ),
                                ]),
                                const Padding(
                                    padding: EdgeInsets.only(top: 15)),
                                IntlPhoneField(
                                  onChanged: (val) {
                                    setState(() {
                                      _phone = val.completeNumber;
                                    });
                                  },
                                  initialValue: _phone,
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
                                  onChanged: (val) {
                                    setState(() {
                                      _website = val;
                                    });
                                  },
                                  initialValue: _website,
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
                                  onChanged: (val) {
                                    setState(() {
                                      _location = val;
                                    });
                                  },
                                  initialValue: _location,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Location is required';
                                    }
                                    return null;
                                  },
                                  decoration:
                                      const InputDecoration(labelText: 'Location'),
                                  keyboardType: TextInputType.streetAddress,
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(top: 15)),
                                TextFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _description = val;
                                    });
                                  },
                                  initialValue: _description,
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
                                  onChanged: (val) {
                                    setState(() {
                                      _email = val;
                                    });
                                  },
                                  initialValue: _email,
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
                      const Spacer(),
                      SizedBox(
                        width: width(context) * 0.8,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_profilePicture != null &&
                                _coverPhoto != null) {
                              if (selectedOption != null) {
                                if (_selectedChip != null) {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .createIgniter,
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .igniterTrial,
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => {
                                              savePlaceProfile(
                                                businessName: _name,
                                                location: _location,
                                                website: _website,
                                                category: _selectedChip,
                                                description: _description,
                                                emailAddress: _email,
                                                phoneNumber: _phone,
                                              ).then((value) => Navigator
                                                  .pushReplacementNamed(context,
                                                      'igniter_dashboard')),
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .proceed),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  showSnackbar(
                                      context, 'Please select a category');
                                }
                              } else {
                                showSnackbar(
                                    context, 'Please select a business type');
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
}
