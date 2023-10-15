import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:provider/provider.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import '../registration/interests.dart';
import 'dart:io';
import '../../user_data/patrone_data.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key, required this.uploadedImage});

  final File uploadedImage;

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String? _selectedChip;

  // Location predictor
  Prediction? generatedPrediction;

  final PageController pageController = PageController();

  // Location Querying

  final TextEditingController _searchController = TextEditingController(),
      _captionController = TextEditingController();

  List<Category> categories = [];
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('New Post'), actions: [
          IconButton(
            onPressed: () {
              if (_selectedChip != null && generatedPrediction != null) {
                try {
                  dataSendingNotifier.startLoading();
                  if (dataSendingNotifier.isLoading) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  Patrone()
                      .uploadPost(
                        widget.uploadedImage,
                        _captionController.text,
                        _selectedChip!,
                        double.parse(generatedPrediction!.lat!),
                        double.parse(generatedPrediction!.lng!),
                      )
                      .then(
                        (value) => Navigator.of(context).pop(),
                      );

                  dataSendingNotifier.stopLoading();
                } on Exception catch (e) {
                  log(e.toString());
                  dataSendingNotifier.stopLoading();
                }
              } else {
                if (_selectedChip == null) {
                  log('No category selected');
                  showSnackbar(context, 'Please select a category');
                }
                if (generatedPrediction == null) {
                  showSnackbar(context, 'Please put the location');
                  log('No location selected');
                }
                if (widget.uploadedImage == null) {
                  log('No image was uploaded');
                  Navigator.pop(context);
                }
              }
            },
            icon: const Icon(Icons.check),
          )
        ]),
        body: SafeArea(
            child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Where are you getting Litt at?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 20),
                    GooglePlacesAutoCompleteTextFormField(
                        textEditingController: _searchController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                        proxyURL: 'https://corsproxy.io/?',
                        decoration: const InputDecoration(
                            hintText: 'Location', labelText: 'Location'),
                        googleAPIKey: "AIzaSyCMFVbr2T_uJwhoGGxu9QZnGX7O5rj7ulQ",
                        debounceTime: 400, // defaults to 600 ms,
                        countries: ["us"], // optional, by
                        // default the list is empty (no restrictions)
                        isLatLngRequired:
                            true, // if you require the coordinates from the place details
                        getPlaceDetailWithLatLng: (prediction) {
                          if (prediction != null) {
                            setState(() {
                              generatedPrediction = prediction;
                            });
                          }
                          print("placeDetails" + prediction.lng.toString());
                        }, // this callback is called when isLatLngRequired is true
                        itmClick: (prediction) {
                          if (prediction != null) {
                            setState(() {
                              _searchController.text = prediction.description!;
                              _searchController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: prediction.description!.length));
                            });
                          }
                        }),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: width(context),
                        child: ElevatedButton(
                          onPressed: () {
                            if (generatedPrediction != null) {
                              pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            } else {
                              showSnackbar(context, 'Please select a location');
                            }
                          },
                          child: const Text('Next'),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: DecorationImage(
                                  image: FileImage(widget.uploadedImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: TextFormField(
                                    controller: _captionController,
                                    maxLength: 100,
                                    minLines: 5,
                                    maxLines: 5,
                                    decoration: const InputDecoration(
                                      labelText: 'Add a caption to your post',
                                      border: InputBorder.none,
                                    )))
                          ]),
                      const SizedBox(height: 20),
                      const Text('Select a category'),
                      const SizedBox(height: 10),
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
                                        _selectedChip =
                                            selected ? chip.display : '';
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text.rich(
                        TextSpan(
                          text: 'Vibing at ',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: generatedPrediction?.description ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text('Share to'),
                      Row(children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.facebook)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.twitter)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.instagram)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.tiktok)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(FontAwesomeIcons.whatsapp)),
                      ])
                    ]),
              )
            ])));
  }
}
