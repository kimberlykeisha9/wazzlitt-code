import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';

import '../../app.dart';
import '../../location/location.dart';
import '../../place/edit_place.dart';

class BusinessOwnerProfile extends StatefulWidget {
  const BusinessOwnerProfile({super.key});

  @override
  State<BusinessOwnerProfile> createState() => _BusinessOwnerProfileState();
}

class _BusinessOwnerProfileState extends State<BusinessOwnerProfile> {
  List<BusinessPlace> listings = [];

  late final Future<List<BusinessPlace>> getBusinessPlaces;
  late final Future<String> Function(DocumentReference<Object?>) getPlaceLocation;

  @override
  void initState() {
    super.initState();
    getBusinessPlaces = BusinessOwner().getListedBusiness();
    getPlaceLocation = (val) {
      return getLocationForPlace(val);
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: FutureBuilder<List<BusinessPlace>>(
            future: getBusinessPlaces,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No businesses available.'));
              } else {
                final listings = snapshot.data!;
                return PageView.builder(
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return _buildBusinessProfile(listing);
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessProfile(BusinessPlace listing) {
    String? openingTime() {
      return listing.openingTime != null
          ? DateFormat('hh:mm a').format(listing.openingTime!)
          : null;
    }

    String? closingTime() {
      return listing.closingTime != null
          ? DateFormat('hh:mm a').format(listing.closingTime!)
          : null;
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  image: listing.coverImage == null
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(listing.coverImage!)),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Hero(
                  tag: 'profile',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                      image: listing.image == null
                          ? null
                          : DecorationImage(
                              image: NetworkImage(listing.image!)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(listing.placeName ?? 'null',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 20),
              const Text('0 Followers'),
              const SizedBox(height: 10),
              const Text('97% Popularity'),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: getPlaceLocation(listing.placeReference!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'Loading...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text(
                      'An error occurred',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditPlace(place: listing.placeReference),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5)),
                        onPressed: () {},
                        child: const Text(
                          'Social Links',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      openingTime() == null
                          ? 'You have not defined your operating hours'
                          : 'Open from ${openingTime()} to ${closingTime()}',
                    ),
                  ),
                  TextButton(
                    child: const Text('Edit'),
                    onPressed: () {},
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'About Us',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    child: const Text(''),
                    onPressed: () {},
                  )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  listing.description ?? 'null',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    child: const Text(''),
                    onPressed: () {},
                  )
                ],
              ),
              listing.services!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: listing.services!.length,
                      itemBuilder: (context, index) {
                        Service service = listing.services![index];
                        return ListTile(
                          trailing: IconButton(
                            onPressed: () => /* Service().deleteService(service, placeData) */ null,
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: service.image == null
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(service.image!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          title: Text(service.title ?? 'null'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${(double.parse(service.price.toString())).toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      },
                    )
                  : const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'You have not listed any services',
                      ),
                    ),
              const SizedBox(height: 20),
              const Text(
                'Tagged Photos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextButton(
                child: const Text('Tap to review'),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          width: width(context),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              height: 150,
              width: width(context) * 0.25,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
