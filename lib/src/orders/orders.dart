import 'package:flutter/material.dart';

import 'order_details.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search orders',
                      prefixIcon: Icon(Icons.search),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                ExpansionTile(title: const Text('Valid orders'), children: [
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetails(
                              orderTitle: 'Valid Order $index',
                            ),
                          ),
                        );
                      },
                      child: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Spacer(flex: 10),
                              Text(
                                'Valid Order $index',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(flex: 3),
                              const Text(
                                '0 Tickets',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                '\$ 0.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(flex: 10),
                            ],
                          )),
                    ),
                  ),
                ]),
                ExpansionTile(
                  title: const Text('Past orders'),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                orderTitle: 'Past Order $index',
                              ),
                            ),
                          );
                        },
                        child: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Spacer(flex: 10),
                                Text(
                                  'Past Order $index',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(flex: 3),
                                const Text(
                                  '0 Tickets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  '\$ 0.00',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(flex: 10),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
