import 'package:flutter/material.dart';
import '../app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: 150,
                color: Colors.grey,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
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
              const Text('User Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('@UserName', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              const Text('User Bio'),
              const SizedBox(height: 10),
              const Text('Star Sign', style: TextStyle(fontSize: 12)),
              const Text('Capricorn',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Posts', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Followers', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Following', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5)),
                        onPressed: () {},
                        child: const Text('Edit Profile',
                            style: TextStyle(fontSize: 12)),
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
                        child: const Text('Social Links',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: SizedBox(
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.place)),
                      Tab(icon: Icon(Icons.favorite)),
                      Tab(icon: Icon(Icons.bookmark)),
                    ],
                    labelColor: Theme.of(context).colorScheme.secondary,
                    unselectedLabelColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.375),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              color: Colors.blue,
                              child: Center(
                                child: Text(
                                  'Post $index',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'Liked $index',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text(
                                  'Saved $index',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
