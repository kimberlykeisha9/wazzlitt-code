import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../user_data/user_data.dart';
import '../app.dart';
import '../registration/interests.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import '../../user_data/patrone_data.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key, required this.uploadedImage});

  final File uploadedImage;

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String? _selectedChip;

  final PageController pageController = PageController();

  // Location Querying

  final TextEditingController _searchController = TextEditingController(),
      _captionController = TextEditingController();

  Placemark? _selectedLocation;

  List<Placemark> _locations = [];
  List<Location> _locationCoordinates = [];
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locations = [];
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          locations[0].latitude, locations[0].longitude,
          localeIdentifier: 'enUS');
      setState(() {
        _locationCoordinates = locations;
        _locations = placemarks;
      });
    } catch (e) {
      print("Error searching location: $e");
    }
  }

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
    return Scaffold(
        appBar: AppBar(title: const Text('New Post'), actions: [
          IconButton(
            onPressed: () {
              print(_locationCoordinates);
              if (_selectedChip != null &&
                  _selectedLocation != null) {
                Patrone().uploadPost(
                  widget.uploadedImage,
                  _captionController.text,
                  _selectedChip!,
                  _locationCoordinates[0].latitude,
                  _locationCoordinates[0].longitude,
                ).then((value) => Navigator.of(context).pop());
              } else {
                if (_selectedChip == null) {
                  log('No category selected');
                  showSnackbar(context, 'Please select a category');
                }
                if (_selectedLocation == null) {
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
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                      controller: _searchController,
                      onChanged: _searchLocation,
                    ),
                    const SizedBox(height: 20),
                    const Text('Suggestions'),
                    const SizedBox(height: 10),
                    Expanded(
                        child: SizedBox(
                      child: ListView.builder(
                          itemCount: _locations.length,
                          itemBuilder: (context, index) {
                            if (_locations == []) {
                              return const Text('No places found');
                            }
                            return ListTile(
                              selected: _selectedLocation == _locations[index],
                              selectedColor:
                                  Theme.of(context).colorScheme.secondary,
                              onTap: () {
                                setState(() {
                                  _selectedLocation = _locations[index];
                                });
                              },
                              leading:
                                  Icon(Icons.place, color: Colors.red[300]),
                              title: Text(_locations[index].name ?? ''),
                              subtitle: Text(
                                  "${_locations[index].street}, ${_locations[index].country}"),
                            );
                          }),
                    )),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: width(context),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedLocation != null) {
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
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: _selectedLocation?.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
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
