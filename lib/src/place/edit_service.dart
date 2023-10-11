import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../../user_data/business_owner_data.dart';
import '../app.dart';

class EditService extends StatefulWidget {
  const EditService({super.key, required this.service, required this.place});
  final Service service;
  final DocumentReference place;

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  int available = 0;
  String? _networkServicePhoto;
  File? _servicePhoto;
  String? _name, _description, _price;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    (widget.service.available ?? false) ? available = 1 : available = 2;
    _name = widget.service.title;
    _networkServicePhoto = widget.service.image;
    _description = widget.service.description;
    _price = widget.service.price.toString();
  }

  Future<void> _pickServicePhoto() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _servicePhoto = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
        appBar: AppBar(title: Text(_name!), actions: [
          TextButton(
              onPressed: () {
                if (_servicePhoto != null || _networkServicePhoto != null) {
                  if (available == 1 || available == 2) {
                    if (_formKey.currentState!.validate()) {
                      try {
                        dataSendingNotifier.startLoading();
                        if (dataSendingNotifier.isLoading) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()));
                        }

                        uploadImageToFirebase(_servicePhoto,
                                'users/${auth.currentUser!.uid}/patrone/services/')
                            .then((value) => Service()
                                .updateService(
                                  place: widget.place,
                                  service: widget.service,
                                  serviceName: _name!,
                                  description: _description!,
                                  image: value,
                                  available: available,
                                  price: double.parse(_price!),
                                )
                                .then((value) => Navigator.pop(context)));
                        dataSendingNotifier.stopLoading();
                      } on Exception catch (e) {
                        dataSendingNotifier.stopLoading();
                      }
                    }
                  } else {
                    showSnackbar(context,
                        'Please choose if your service is currently available');
                  }
                } else {
                  showSnackbar(
                      context, 'Please upload an image for your service');
                }
              },
              child: const Text('Save'))
        ]),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                GestureDetector(
                  onTap: () => _pickServicePhoto(),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: _networkServicePhoto != null
                          ? DecorationImage(
                              image: NetworkImage(_networkServicePhoto!),
                              fit: BoxFit.cover,
                            )
                          : _servicePhoto == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(_servicePhoto!),
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Product Image'),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    if (val == null) {
                      return 'Please input a name';
                    }
                    return null;
                  },
                  initialValue: _name,
                  onChanged: (val) {
                    setState(() {
                      _name = val;
                    });
                  },
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Service name*'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    if (val == null) {
                      return 'Please describe your service';
                    }
                    return null;
                  },
                  initialValue: _description,
                  onChanged: (val) {
                    setState(() {
                      _description = val;
                    });
                  },
                  minLines: 5,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Description*'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (val) {
                    if (val == null) {
                      return 'Please enter a price';
                    }
                    if (val == null) {
                      return 'Please enter a price';
                    }
                    const digitPattern = r'^\d+$';
                    if (!RegExp(digitPattern).hasMatch(val)) {
                      return 'Please enter a digit';
                    }
                    return null;
                  },
                  initialValue: _price,
                  onChanged: (val) {
                    setState(() {
                      _price = val;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price*'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Is this product still available?'),
                    const Spacer(flex: 6),
                    Radio(
                        value: 1,
                        groupValue: available,
                        onChanged: (val) {
                          setState(() => available = val!);
                        }),
                    const Spacer(),
                    const Text('Yes'),
                    const Spacer(),
                    Radio(
                        value: 2,
                        groupValue: available,
                        onChanged: (val) {
                          setState(() => available = val!);
                        }),
                    const Spacer(),
                    const Text('No'),
                  ],
                ),
              ]),
            ),
          ),
        )));
  }
}
