import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app.dart';

class UploadImage extends StatefulWidget {
  UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String _selectedChip = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('New Post'), actions: [
          IconButton(
            onPressed: () {
              showSnackbar(context, 'Posted');
            },
            icon: const Icon(Icons.check),
          )
        ]),
        body: SafeArea(
            child: PageView(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Where are you getting Litt at?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 20),
                TextFormField(decoration: const InputDecoration(labelText: 'Search')),
                const SizedBox(height: 20),
                const Text('Suggestions'),
                const SizedBox(height: 10),
                Expanded(
                    child: SizedBox(
                  child: ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.favorite),
                          title: Text('Location $index'),
                          subtitle: const Text('Street Name'),
                        );
                      }),
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  color: Colors.grey,
                  width: 100,
                  height: 150,
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
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
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(chip),
                            selected: _selectedChip == chip,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChip = selected ? chip : '';
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),
              const Text.rich(
                TextSpan(
                  text: 'Vibing at ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '**Tagged Location**',
                      style: TextStyle(
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
                    onPressed: () {}, icon: const Icon(FontAwesomeIcons.facebook)),
                IconButton(
                    onPressed: () {}, icon: const Icon(FontAwesomeIcons.twitter)),
                IconButton(
                    onPressed: () {}, icon: const Icon(FontAwesomeIcons.instagram)),
                IconButton(
                    onPressed: () {}, icon: const Icon(FontAwesomeIcons.tiktok)),
                IconButton(
                    onPressed: () {}, icon: const Icon(FontAwesomeIcons.whatsapp)),
              ])
            ]),
          )
        ])));
  }
}
