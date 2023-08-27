import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wazzlitt/src/location/location.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _openingTimeTextController = TextEditingController();
  TextEditingController _closingTimeTextController = TextEditingController();

  // Location predictor
  Prediction? generatedPrediction;

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
    widget.place?.get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? placeData = value.data() as Map<String, dynamic>?;
        _nameController = TextEditingController(text: placeData?['place_name']);
        _phoneController = TextEditingController(text: placeData?['phone_number']);
        _websiteController = TextEditingController(text: placeData?['website']);
        // _locationController = TextEditingController(text: placeData?['location']);
        _descriptionController = TextEditingController(text: placeData?['place_description']);
        _emailController = TextEditingController(text: placeData?['email_address']);
        networkCoverPhoto = placeData?['cover_image'];
        networkProfile = placeData?['image'];
        _openingTime = placeData?['opening_time'];
        _closingTime = placeData?['closing_time'];
        _selectedChip = placeData?['category'];
        selectedOption = placeData?['place_type'];
        _openingTime != null
            ? _openingTimeTextController =
                TextEditingController(text: DateFormat.Hm().format(_openingTime!.toDate()))
            : '';
        _closingTime != null
            ? _closingTimeTextController =
                TextEditingController(text: DateFormat.Hm().format(_closingTime!.toDate()))
            : '';
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
            future: widget.place?.get(const GetOptions(source: Source.server)),
            builder: (context, snapshot) {
              if (snapshot.hasData || snapshot.connectionState == ConnectionState.none) {
                Map<String, dynamic>? placeData;
                if (widget.place != null) {
                  widget.place!.get().then((data) {
                    placeData = data.data() as Map<String, dynamic>?;
                    print(placeData);
                  });
                }
                print(placeData);
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
                                      hint:
                                          const Text('Select your business type'),
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
                                                    _selectedChip == chip.display,
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
                                              _openingTimeTextController.text =
                                                  DateFormat.Hm().format(
                                                      _openingTime!.toDate());
                                            });
                                          },
                                          controller: _openingTimeTextController,
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
                                                      _openingTimeTextController
                                                              .text =
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
                                              _closingTimeTextController.text =
                                                  DateFormat.Hm().format(
                                                      _closingTime!.toDate());
                                            });
                                          },
                                          controller: _closingTimeTextController,
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
                                                      _closingTimeTextController
                                                              .text =
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
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.phone,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      // if (value == null) {
                                      //   return 'Phone number is required';
                                      // }
                                      return null; // Return null if the input is valid
                                    },
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  TextFormField(
                                    controller: _websiteController,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Website is required';
                                    //   }
                                    //   return null;
                                    // },
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .website),
                                    keyboardType: TextInputType.url,
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 15)),
                                  GooglePlacesAutoCompleteTextFormField(
                                      textEditingController:
                                      _locationController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Location is required';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Location',
                                          labelText: 'Location'),
                                      googleAPIKey: "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ",
                                      debounceTime: 400, // defaults to 600 ms,
                                      countries: ["us"], // optional, by
                                      // default the list is empty (no restrictions)
                                      isLatLngRequired: true, // if you require the coordinates from the place details
                                      getPlaceDetailWithLatLng: (prediction) {
                                        if(prediction != null) {
                                          setState(() {
                                            generatedPrediction = prediction;
                                          });
                                        }
                                        print("placeDetails" + prediction.lng.toString());
                                      }, // this callback is called when isLatLngRequired is true
                                      itmClick: (prediction) {
                                        if(prediction != null) {
                                          setState(() {
                                            _locationController.text =
                                            prediction.description!;
                                            _locationController.selection =
                                                TextSelection.fromPosition
                                                  (TextPosition(offset:
                                                prediction.description!.length));
                                          });
                                        }
                                      }
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
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Email is required';
                                    //   }
                                    //   if (!RegExp(
                                    //           r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    //       .hasMatch(value)) {
                                    //     return 'Invalid email address';
                                    //   }
                                    //   return null;
                                    // },
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
                                    _coverPhoto != null) ||
                                (networkProfile != null &&
                                    networkCoverPhoto != null)) {
                              if (selectedOption != null) {
                                if (_selectedChip != null) {
                                  if (_formKey.currentState!.validate()) {
                                    placeData == null
                                        ? showDialog(
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
                                                  onPressed: () {
                                                    uploadPlaceLocation(widget
                                                      .place!,
                                                      double.parse(generatedPrediction
                                                      !.lat!),
                                                      double.parse
                                                        (generatedPrediction!.lng!));
                                                    savePlaceProfile(
                                                      businessName:
                                                    _nameController.text,
                                                website:
                                                    _websiteController.text,
                                                category: _selectedChip,
                                                description:
                                                    _descriptionController.text,
                                                emailAddress:
                                                    _emailController.text,
                                                latitude: double.parse
                                                  (generatedPrediction!.lat!),
                                                longitude: double.parse
                                                  (generatedPrediction!.lng!),
                                                phoneNumber:
                                                    _phoneController.text,
                                                    ).then((value) => Navigator
                                                        .pushReplacementNamed(
                                                            context,
                                                            'igniter_dashboar'
                                                                'd'));
                                                  },
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .proceed),
                                                ),
                                              ],
                                            ),
                                          )
                                        : uploadImageToFirebase(_coverPhoto,
                                                'places/${widget.place!.id}/coverPhoto')
                                            .then((coverPic) {
                                            uploadImageToFirebase(
                                                    _profilePicture,
                                                    'places/${widget.place?.id}/profile_photo')
                                                .then((profilePic) {
                                                  uploadPlaceLocation(widget
                                                      .place!,
                                                      double.parse(generatedPrediction
                                                      !.lat!),
                                                      double.parse
                                                        (generatedPrediction!.lng!));
                                              savePlaceProfile(
                                                businessName:
                                                    _nameController.text,
                                                website:
                                                    _websiteController.text,
                                                category: _selectedChip,
                                                description:
                                                    _descriptionController.text,
                                                emailAddress:
                                                    _emailController.text,
                                                latitude: double.parse
                                                  (generatedPrediction!.lat!),
                                                longitude: double.parse
                                                  (generatedPrediction!.lng!),
                                                phoneNumber:
                                                    _phoneController.text,
                                              ).then((value) =>
                                                  Navigator.popAndPushNamed(
                                                      context,
                                                      'igniter_dashboard'));
                                            });
                                          });
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
