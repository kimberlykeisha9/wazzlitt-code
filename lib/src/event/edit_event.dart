import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../registration/interests.dart';

class EditEvent extends StatefulWidget {
  const EditEvent({super.key, this.event});
  final DocumentReference? event;

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  // Form Controller
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Time
  Timestamp? _date;

  // Images from Network
  String? networkEventImage;
  // Local Images
  File? _localEventImage;

  // Selected Category
  String? _selectedChip;

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    // Fill in the text controller values
    WidgetsFlutterBinding.ensureInitialized();
    widget.event?.get().then((value) {
      if (value.exists) {
        Map<String, dynamic>? eventData =
            value.data() as Map<String, dynamic>?;
        _nameController.text = eventData?['event_name'] ?? '';
        _descriptionController.text = eventData?['event_description'] ?? '';
        _locationController.text = eventData?['location']?? '';
        _date = eventData?['date'] as Timestamp?;
        _date != null ? _dateController.text = DateFormat.yMEd().format(_date!.toDate()) : null;
        _selectedChip = eventData?['category'];
        networkEventImage = eventData?['image'];
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

  Future<void> _pickEventImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _localEventImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Event'),
          actions: [
            widget.event != null ? TextButton(
              child: const Text('Delete'),
              onPressed: () {
                if (widget.event != null) {
                  widget.event?.delete().then((value) => Navigator.pop(context));
                }
              }
            ) : const SizedBox(),
          ]
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: widget.event?.get(),
            builder: (context, snapshot) {
              if (snapshot.hasData || snapshot.connectionState == ConnectionState.none) {
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                          height: 200,
                          width: width(context),
                          child: GestureDetector(
                            onTap: () {
                              _pickEventImage(); // Function to handle cover photo selection
                            },
                            child: Container(
                              width: width(context),
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: networkEventImage != null
                                    ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(networkEventImage!))
                                    : _localEventImage == null
                                    ? null
                                    : DecorationImage(
                                  fit: BoxFit.cover,
                                    image:
                                    FileImage(_localEventImage!)),
                              ),
                              child: (_localEventImage != null ||
                                  networkEventImage != null)
                                  ? const SizedBox()
                                  : const Icon(Icons.add_photo_alternate),
                            ),
                          )),
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
                                        return 'Event name is required';
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
                                  TextFormField(
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(
                                          DateTime
                                              .now()
                                              .year + 1,
                                          DateTime
                                              .now()
                                              .month,
                                          DateTime
                                              .now()
                                              .day,
                                        ),
                                      ).then((selectedDate) {
                                        if (selectedDate != null) {
                                          setState(() {
                                            _date = Timestamp.fromDate(
                                                selectedDate);
                                            _dateController.text =
                                                DateFormat.yMEd().format(
                                                    selectedDate);
                                          });
                                        }
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Event date is required';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Event Date',
                                    ),
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                    TextCapitalization.words,
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
                                            (chip) =>
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: ChoiceChip(
                                                label: Text(chip.display),
                                                selected: _selectedChip ==
                                                    chip.display,
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
                                  TextFormField(
                                    controller: _locationController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Location is required';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        labelText: 'Location'),
                                    keyboardType: TextInputType.streetAddress,
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
                            if ((networkEventImage != null ||
                                _localEventImage != null)) {
                              if (_selectedChip != null) {
                                if (_formKey.currentState!.validate()) {
                                  uploadImageToFirebase(_localEventImage,
                                      'event/${widget.event?.id}/event_image')
                                      .then((eventPic) {
                                    EventData().saveEvent(
                                      event: widget.event,
                                      eventName: _nameController.text,
                                      location: _locationController.text,
                                      category: _selectedChip,
                                      date: _date,
                                      description: _descriptionController.text,
                                      eventPhoto: eventPic ?? networkEventImage,
                                    ).then((value) =>
                                        Navigator.popAndPushNamed(
                                            context, 'igniter_dashboard'));
                                  });
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
}
