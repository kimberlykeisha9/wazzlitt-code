import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../../utils/categories.dart';
import '../app.dart';

class EditEvent extends StatefulWidget {
  const EditEvent({super.key, this.event});
  final DocumentReference? event;

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  // Form Controller
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Time
  Timestamp? _date;

  // Location predictor
  Prediction? generatedPrediction;

  // Images from Network
  String? networkEventImage;
  // Local Images
  File? _localEventImage;

  // Selected Category
  String? _selectedChip;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() async {
    if (widget.event != null) {
      final eventSnapshot = await widget.event!.get();
      if (eventSnapshot.exists) {
        final eventData = eventSnapshot.data() as Map<String, dynamic>?;
        _nameController.text = eventData?['event_name'] ?? '';
        _descriptionController.text = eventData?['event_description'] ?? '';
        _date = eventData?['date'] as Timestamp?;
        if (_date != null) {
          _dateController.text = DateFormat.yMEd().format(_date!.toDate());
        }
        _selectedChip = eventData?['category'];
        networkEventImage = eventData?['image'];
      }
    }
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
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          if (widget.event != null)
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await widget.event?.delete();
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget.event?.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData ||
              snapshot.connectionState == ConnectionState.none) {
            return SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickEventImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        image: networkEventImage != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(networkEventImage!),
                              )
                            : _localEventImage != null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(_localEventImage!),
                                  )
                                : null,
                      ),
                      child:
                          networkEventImage == null && _localEventImage == null
                              ? const Icon(Icons.add_photo_alternate)
                              : null,
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  labelText: AppLocalizations.of(context)!.name,
                                ),
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      _date = Timestamp.fromDate(selectedDate);
                                      _dateController.text = DateFormat.yMEd()
                                          .format(selectedDate);
                                    });
                                  }
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
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                AppLocalizations.of(context)!.selectCategory,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 15),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: categories.map((chip) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ChoiceChip(
                                        label: Text(chip),
                                        selected: _selectedChip == chip,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedChip =
                                                selected ? chip : '';
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 15),
                              GooglePlacesAutoCompleteTextFormField(
                                textEditingController: _locationController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Location is required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Location',
                                  labelText: 'Location',
                                ),
                                googleAPIKey: "MAPS_API_KEY",
                                debounceTime: 400,
                                countries: ["us"],
                                isLatLngRequired: true,
                                getPlaceDetailWithLatLng: (prediction) {
                                  if (prediction != null) {
                                    setState(() {
                                      generatedPrediction = prediction;
                                    });
                                  }
                                },
                                itmClick: (prediction) {
                                  if (prediction != null) {
                                    setState(() {
                                      _locationController.text =
                                          prediction.description!;
                                      _locationController.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(
                                            offset:
                                                prediction.description!.length),
                                      );
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
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
                                      AppLocalizations.of(context)!.description,
                                ),
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_localEventImage != null ||
                            networkEventImage != null) {
                          if (_selectedChip != null) {
                            if (_formKey.currentState!.validate()) {
                              try {
                                dataSendingNotifier.startLoading();
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const Center(
                                      child: CircularProgressIndicator()),
                                );
                                final eventPic = await uploadImageToFirebase(
                                  _localEventImage,
                                  'event/${widget.event?.id}/event_image',
                                );
                                await EventData().saveEvent(
                                  event: widget.event,
                                  eventName: _nameController.text,
                                  location: _locationController.text,
                                  category: _selectedChip,
                                  date: _date?.toDate(),
                                  latitude:
                                      double.parse(generatedPrediction!.lat!),
                                  longitude:
                                      double.parse(generatedPrediction!.lng!),
                                  description: _descriptionController.text,
                                  eventPhoto: eventPic ?? networkEventImage,
                                );
                                dataSendingNotifier.stopLoading();
                                Navigator.popAndPushNamed(
                                    context, 'igniter_dashboard');
                              } catch (e) {
                                dataSendingNotifier.stopLoading();
                                // Handle error (e.g., show a snackbar or dialog)
                              }
                            }
                          } else {
                            showSnackbar(context, 'Please select a category');
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
        },
      ),
    );
  }
}
