import 'package:flutter/material.dart';
import '../app.dart';

class NewService extends StatefulWidget {
  const NewService({super.key});

  @override
  State<NewService> createState() => _NewServiceState();
}

class _NewServiceState extends State<NewService> {
  int available = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('New Service Details'), actions: [
          TextButton(
              onPressed: () {
                showSnackbar(context, 'Saved new product');
              },
              child: const Text('Save'))
        ]),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(
              color: Colors.grey,
              width: 150,
              height: 150,
            ),
            const Spacer(),
            const Text('Product Image'),
            const Spacer(),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Service name*'),
            ),
            const Spacer(),
            TextFormField(
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Description*'),
            ),
            const Spacer(),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price*'),
            ),
            const Spacer(),
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
            const Spacer(flex: 3),
          ]),
        )));
  }
}
