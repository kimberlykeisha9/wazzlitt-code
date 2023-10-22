import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/business_owner_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../app.dart';

class NewService extends StatefulWidget {
  const NewService({super.key, required this.place});

  final DocumentReference place;

  @override
  State<NewService> createState() => _NewServiceState();
}

class _NewServiceState extends State<NewService> {
  int available = 0;
  var _servicePhoto;
  TextEditingController? _nameController,
      _descriptionController,
      _priceController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('New Service Details'), actions: [
          TextButton(
              onPressed: () {
                if (_servicePhoto != null) {
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

                        uploadImageToFirebase(_servicePhoto!,
                                'users/${auth.currentUser!.uid}/patrone/services/')
                            .then((value) => Service()
                                .addNewService(
                                  place: widget.place,
                                  serviceName: _nameController?.text,
                                  description: _descriptionController?.text,
                                  image: value,
                                  available: available,
                                  price: double.parse(_priceController!.text),
                                )
                                .then((value) => Navigator.pop(context)));
                        dataSendingNotifier.stopLoading();
                      } on Exception {
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
                  onTap: () {
                    selectImage().then((value) {
                      _servicePhoto = value;
                    });
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: _servicePhoto == null
                          ? null
                          : kIsWeb ? DecorationImage(
                              image: MemoryImage(_servicePhoto!),
                              fit: BoxFit.cover,
                            ) :DecorationImage(
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
                  controller: _nameController,
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
                  controller: _descriptionController,
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
                    const digitPattern = r'^\d+$';
                    if (!RegExp(digitPattern).hasMatch(val)) {
                      return 'Please enter a digit';
                    }
                    return null;
                  },
                  controller: _priceController,
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
