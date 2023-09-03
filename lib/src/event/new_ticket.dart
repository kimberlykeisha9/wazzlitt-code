
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/event_organizer_data.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';

class NewTicket extends StatefulWidget {
  const NewTicket({super.key, required this.event});

  final EventData event;

  @override
  State<NewTicket> createState() => _NewTicketState();
}

class _NewTicketState extends State<NewTicket> {
  int available = 0;
  DateTime? _expiry;
  TextEditingController? _nameController, _descriptionController, _priceController, _expiryDateController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _expiryDateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final dataSendingNotifier = Provider.of<DataSendingNotifier>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('New Ticket Details'), actions: [
          TextButton(
              onPressed: () {

                  if(available == 1 || available == 2) {
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

  Ticket().addNewTicket(
    event: widget.event.eventReference!,
    ticketName: _nameController?.text, description: _descriptionController?.text, available: available, price: double.parse(_priceController!.text),
  ).then((value) => Navigator.pop(context));
  dataSendingNotifier.stopLoading();
} on Exception catch (e) {
  dataSendingNotifier.stopLoading();
}
                    }
                  } else {
                    showSnackbar(context, 'Please choose if your service is currently available');
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
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please input a ticket name';
                        }
                        return null;
                      },
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Ticket name*'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _expiryDateController,
                      readOnly: true,
                      onTap: () => showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: widget.event.date!).then((value) {
                        setState(() {
                          _expiry = value;
                          if (value != null) {
                            _expiryDateController!.text = DateFormat('E, dd/MM/yyyy').format(value);
                          }
                        });
                      }),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Ticket Expiry Date'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please describe your ticket';
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
                        if (val == null || val.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (val == null) {
                          return 'Please enter a price';
                        }
                        const digitPattern = r'^\d+$';
                        if(!RegExp(digitPattern).hasMatch(val)) {
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
                        const Text('Is this ticket still available?'),
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
