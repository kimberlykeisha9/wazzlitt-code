
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';

class EditTicket extends StatefulWidget {
  const EditTicket({super.key, required this.event, required this.ticket});
  final Map<String, dynamic> ticket;
  final DocumentReference event;

  @override
  State<EditTicket> createState() => _EditTicketState();
}

class _EditTicketState extends State<EditTicket> {
  int available = 0;
  Timestamp? _expiryDate;
  TextEditingController _nameController = TextEditingController(), _descriptionController = TextEditingController(),
      _priceController = TextEditingController(), _expiryDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.ticket['available'] ? available = 1 : available = 2;
    _nameController.text = widget.ticket['ticket_name'] ?? '';
    _expiryDate = widget.ticket['expiry_date'];
    _expiryDate != null ? _expiryDateController.text = DateFormat('E, dd/MM/yyyy').format(_expiryDate!.toDate()) : null;
    _descriptionController.text = widget.ticket['ticket_description'] ?? '';
    _priceController.text = widget.ticket['price'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Ticket Details'), actions: [
          TextButton(
              onPressed: () {
                  if(available == 1 || available == 2) {
                    if (_formKey.currentState!.validate()) {
                      updateTicket(
                        event: widget.event, ticket: widget.ticket,
                        ticketName: _nameController.text, description: _descriptionController.text, expiry: _expiryDate, available: available, price: double.parse(_priceController.text),
                      ).then((value) => Navigator.pop(context));
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
                      controller: _expiryDateController,
                      readOnly: true,
                      onTap: () => showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 1)).then((value) {
                        setState(() {

                          if (value != null) {
                            _expiryDate = Timestamp.fromDate(value);
                            _expiryDateController.text = DateFormat('E, dd/MM/yyyy').format(value);
                          }
                        });
                      }),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Ticket Expiry Date'),
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
