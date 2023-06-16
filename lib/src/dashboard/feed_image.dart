import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app.dart';

class FeedImage extends StatefulWidget {
  const FeedImage({
    super.key,
  });

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage> {
  String? selectedReason;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: width(context),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/igniter-2.png')),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('User Caption',
                      style: TextStyle(color: Colors.white)),
                ),
                Container(
                  width: width(context),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.25),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const Spacer(),
                        const Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.start,
                          children: [
                            Text('User Name',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text('0 days ago',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const Spacer(flex: 4),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(
                            FontAwesomeIcons.heart,
                            color: Colors.white,
                          ),
                        ),
                        const Text('0', style: TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(FontAwesomeIcons.message,
                              color: Colors.white),
                        ),
                        const Text('0', style: TextStyle(color: Colors.white)),
                        IconButton(
                          onPressed: () {},
                          icon: const FaIcon(FontAwesomeIcons.share,
                              color: Colors.white),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            showPopupMenu(context);
                          },
                        ),
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: width(context),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.75),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.place, color: Colors.white),
                      Spacer(),
                      Text('Tagged Location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Spacer(flex: 16),
                      Text('0 km away', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = Offset(overlay.size.width / 2, overlay.size.height);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'report',
          child: Text('Report'),
        ),
        const PopupMenuItem(
          value: 'block',
          child: Text('Block User'),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value == 'report') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Make a Report'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedReason = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Reason for Report',
                      // border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Spam',
                        child: Text('Spam'),
                      ),
                      DropdownMenuItem(
                        value: 'Harassment',
                        child: Text('Harassment'),
                      ),
                      DropdownMenuItem(
                        value: 'Inappropriate Content',
                        child: Text('Inappropriate Content'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Any further information?'),
                    minLines: 1,
                    maxLines: 5,
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () {}, child: const Text('Submit Report'))
              ]),
        );
      } else if (value == 'block') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text('Block User'),
              content: const Text('Are you sure you want to block this user?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Yes, I am sure'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ]),
        );
      }
    });
  }
}
