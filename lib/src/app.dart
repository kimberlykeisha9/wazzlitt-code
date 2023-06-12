import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings/settings_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
              tabBarTheme: TabBarTheme(labelColor: Colors.indigo[900]),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: Colors.indigo[900]),
              appBarTheme: AppBarTheme(
                color: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 16),
                toolbarHeight: height(context) * 0.1,
                iconTheme: IconThemeData(color: Colors.indigo[900]!),
              ),
              chipTheme: ChipThemeData(
                  backgroundColor: Colors.greenAccent[100],
                  selectedColor: Colors.greenAccent[400]),
              inputDecorationTheme: InputDecorationTheme(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              textTheme: const TextTheme(
                labelLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 16),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
              colorScheme: ColorScheme.light(
                  primary: Colors.indigo[900]!,
                  secondary: Colors.greenAccent[400]!)),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: 'patrone_dashboard',
          routes: {
            'home': (context) => const Home(),
            'signup': (context) => const SignUp(),
            'patrone_registration': (context) => PatroneRegistration(),
            'interests': (context) => const Interests(),
            'igniter_registration': (context) => const IgniterRegistration(),
            'igniter_profile': (context) => IgniterProfile(),
            'patrone_dashboard': (context) => const PatroneDashboard(),
            'settings': (context) => const Settings(),
            'orders': (context) => const Orders(),
            'confirmed': (context) => const ConfirmedOrder(),
            'igniter_dashboard': (context) => const IgniterDashboard(),
            // 'place_order': (context) => PlaceOrder(),
          },
        );
      },
    );
  }
}

class ServiceOverview extends StatefulWidget {
  const ServiceOverview({super.key, required this.serviceTitle});

  final String serviceTitle;

  @override
  State<ServiceOverview> createState() => _ServiceOverviewState();
}

class _ServiceOverviewState extends State<ServiceOverview> {
  DateTime period = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        period = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  color: Colors.grey,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(widget.serviceTitle, style: const TextStyle(fontWeight: FontWeight
                    .bold, fontSize: 20)),
                const SizedBox(height: 10),
                const Text('Product Brief Description'),
                const SizedBox(height: 10),
                const Text('\$0.00'),
                const SizedBox(height: 20),
                    const Text('Overview',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Total Gross Sales', style: TextStyle
                          (fontWeight: FontWeight.bold)), Text('\$0.00',
                        )]),
                    const SizedBox(height: 5),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Units Sold', style: TextStyle
                          (fontWeight: FontWeight.bold)),
                          Text
                          ('0')]),
                    const SizedBox(height: 10),
                const Text('Sales History',
                    style: TextStyle(fontWeight: FontWeight.bold)),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(DateFormat.yMMMM().format(period),
                        style:
                    const TextStyle
                      (fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text
                          ('Choose Month'),
                      )]),

                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Sales of Period', style: TextStyle
                      (fontWeight: FontWeight.bold)),
                      Text
                        ('\$ 0.00')]),
                const SizedBox(height: 20),
                const Text('Last 5 Transactions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                flex: 2,
                        child: Text('Date', style: TextStyle(fontWeight:
                        FontWeight.bold, fontSize: 12)),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                        flex: 3,
                      child: Text('Transaction ID', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12)),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text('Quantity', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12), textAlign: TextAlign
                          .right),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text('Amount', style: TextStyle(fontWeight:
                      FontWeight.bold, fontSize: 12), textAlign: TextAlign
                          .right),
                    ),
                  ]
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                    height: 40,
                      width: width(context),
                      alignment: Alignment.center,
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                    flex: 2,
                            child: Text('01/Jan/2023', style: TextStyle(fontSize:
                            14)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('ABCD-EFGH-IJKL', style: TextStyle
                              ( fontSize: 14)),
                          ),
                          Expanded(
                            child: Text('0', style: TextStyle(fontSize: 14), textAlign: TextAlign.right),
                          ),
                          Expanded(
                            child: Text('\$ 0.00', style: TextStyle(fontSize: 14), textAlign: TextAlign.right),
                          ),
                        ]
                    ),
                    )
                  ),
              ],
            ),
          ),
        )
      ),
    );
  }
}


class IgniterDashboard extends StatefulWidget {
  const IgniterDashboard({super.key});

  @override
  State<IgniterDashboard> createState() => _IgniterDashboardState();
}

class _IgniterDashboardState extends State<IgniterDashboard> {
  var _currentIndex = 0;
  DateTime period = DateTime.now();
  List<String> getCurrentWeek() {
    final DateTime monday = period.subtract(Duration(days: period.weekday - 1));
    final DateFormat formatter = DateFormat('MMM d');

    final List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final List<String> formattedDates =
        weekDays.map((date) => formatter.format(date)).toList();

    return formattedDates;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        period = pickedDate;
      });
    }
  }

  List<Widget> view(BuildContext) {
    return [
      dashboard(context),
      const ChatsView(chatType: ChatRoomType.business),
      profile(context)
    ];
  }

  @override
  Widget build(BuildContext context) {
    getCurrentWeek();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: view(context)[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Theme.of(context).colorScheme.primary,
        ),
        child: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Messages', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
          ],
        ),
      ),
    );
  }

  SafeArea dashboard(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 60,
                width: 60,
                decoration:
                    const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
            const Text('Business Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 20),
            const Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    Text('Daily Stats Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Services Sold',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('Revenue Earned',
                                  style: TextStyle(fontSize: 12)),
                              Text('\$0.00',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Daily Chats',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('Tagged Posts',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Daily Impressions',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('New Followers',
                                  style: TextStyle(fontSize: 12)),
                              Text('0',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ])
                  ]),
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Services Overview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Week (${getCurrentWeek()[0]} - ${getCurrentWeek()[6]})'),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Change Period'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Service $index',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Sales'), Text('\$0.00')]),
                        const SizedBox(height: 5),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('Units Sold'), Text('0')]),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width(context),
                    child: ElevatedButton(
                      child: const Text('Add a new service'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewService(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Performance Overview',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Chats received today'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Reports received'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Tagged posts'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Followers'), Text('0')]),
                  const SizedBox(height: 5),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Profile Visits (Monthly'), Text('0')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SafeArea profile(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
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
                  const Text('Business Name',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  const Text('0 Followers'),
                  const SizedBox(height: 10),
                  const Text('97% Popularity'),
                  const SizedBox(height: 10),
                  const Text('Something Street, Town', style: TextStyle(fontSize: 14)),
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
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Open - 09:00 AM to 09:00 PM'),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Praesent vel enim ipsum. Donec sit amet scelerisque justo, non'
                        ' eleifend sem. Phasellus vestibulum sapien quis sodales accumsan. '
                        'Ut consectetur felis id nunc volutpat tristique. Suspendisse '
                        'euismod volutpat augue nec bibendum. In ut nisl odio. Quisque '
                        'diam risus, pharetra suscipit egestas sit amet, laoreet feugiat '
                        'nunc. Phasellus bibendum dui at sapien consequat, vel vestibulum '
                        'elit consequat. Sed ullamcorper tortor mauris, eu volutpat turpis'
                        ' hendrerit at.',
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Services', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      child: const Text('Edit'),
                      onPressed: () {},
                    )
                  ]),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => ServiceOverview
                              (serviceTitle: 'Service $index'),
                          ),
                          );
                        },
                          leading: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                          ),
                          title: Text('Service $index'),
                          subtitle: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Product Brief Description'),
                                Text('\$0.00'),
                              ]))),
                  const SizedBox(height: 20),
                  const Text('Tagged Photos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        ),
      ),
    );
  }
}

class ConfirmedOrder extends StatelessWidget {
  const ConfirmedOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          const Spacer(flex: 4),
          const Icon(FontAwesomeIcons.champagneGlasses, size: 60),
          const Spacer(),
          const Text('It\'s Litt!!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text('You have successfully placed your order for **ORDER**. Check '
              'your email for an invoice and the orders panel for your '
              'transaction details.'),
          const Spacer(),
          SizedBox(
              width: width(context),
              child: ElevatedButton(
                  child: const Text('Return to home'),
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          const Spacer(flex: 4),
        ]),
      ),
    );
  }
}

enum OrderType { event, service }

class PlaceOrder extends StatefulWidget {
  PlaceOrder({super.key, required this.orderType, required this.orderTitle});

  final OrderType orderType;
  final String orderTitle;

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

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

class _PlaceOrderState extends State<PlaceOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderType == OrderType.service
            ? 'Services for ${widget.orderTitle}'
            : 'Tickets for ${widget.orderTitle}'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(widget.orderTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(widget.orderType == OrderType.service
              ? 'Choose which services you would like to order'
              : 'Choose which tickets you would like to order'),
          const Spacer(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              int quantity = 1;

              void increment() {
                setState(() {
                  quantity++;
                });
              }

              void decrement() {
                if (quantity > 1) {
                  setState(() {
                    quantity--;
                  });
                }
              }

              return widget.orderType == OrderType.service
                  ? ListTile(
                      title: Text('Service $index'),
                      subtitle: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$ 0.00'),
                          Text('Service description'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: decrement,
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: increment,
                          ),
                        ],
                      ))
                  : ListTile(
                      title: Text('Ticket Type $index'),
                      subtitle: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$ 0.00'),
                          Text('Ticket type description'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: decrement,
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: increment,
                          ),
                        ],
                      ));
            },
          ),
          const Spacer(flex: 3),
          CheckboxListTile(
              value: true,
              onChanged: (val) {},
              subtitle: const Text('I confirm that I am liable to the Terms and '
                  'Conditions of this purchase and all other regulations set.')),
          const Spacer(flex: 3),
          SizedBox(
              width: width(context),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, 'confirmed');
                  },
                  child: const Text('Checkout'))),
          const Spacer(flex: 5),
        ]),
      )),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.privacyInfo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.profileVisibility),
                        DropdownButton<String>(
                          value: 'Public',
                          onChanged: (String? value) {
                            if (value == 'Public') {
                              // Handle Public option
                            } else if (value == 'Private') {
                              // Handle Private option
                            }
                          },
                          items: <String>[
                            'Public',
                            'Private',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.allowMessages),
                        DropdownButton<String>(
                          value: 'Everyone',
                          onChanged: (String? value) {
                            if (value == 'Everyone') {
                              // Handle Public option
                            } else if (value == 'Followers') {
                              // Handle Private option
                            } else if (value == 'Followers I follow back') {
                              // Handle
                            }
                          },
                          items: <String>[
                            'Everyone',
                            'Followers',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.blocked),
                      const Text('0'),
                    ],
                  ),
                  Text(AppLocalizations.of(context)!.dataUsage),
                  const Text('Notification Settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Push Notifications'),
                  const Text('Email Notifications'),
                  const Text('SMS Notifications'),
                  const Text('Language and Localizations',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Language'),
                  const Text('Date format'),
                  const Text('Currency'),
                  const Text('Connected Accounts',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Facebook'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Twitter'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Instagram'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Email'),
                      Switch(value: false, onChanged: (val) => val = true),
                    ],
                  ),
                  const Text('Help and Support',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('FAQ and Help Centre'),
                  const Text('Contact Support'),
                  const Text('About and Legal Information',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('App Version'),
                      Text('1.0.0'),
                    ],
                  ),
                  const Text('Terms of Service'),
                ],
              ),
            ),
          ),
        ));
  }
}

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key, this.orderTitle});

  final String? orderTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.orderTitle ?? ''),
      ),
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: Container(
            color: Colors.grey,
          ),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(orderTitle ?? 'null',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const Spacer(),
                const Center(child: Text('Order Address')),
                const Spacer(flex: 3),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Order Content', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Quantity',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Order Quantity', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Price',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('\$ 0.00', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Validity Date: 01 January 2023',
                    style: TextStyle(fontSize: 14)),
                const Spacer(flex: 3),
                const Text('Payment Status: Completed',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Purchase Date: 01 January 2023',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Order ID: ABCD-EFGH-IJKL-MNOP',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text('Transaction Type: Credit Card',
                    style: TextStyle(fontSize: 14)),
                const Spacer(flex: 3),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Request Invoice')),
                ),
                const Spacer(),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Raise Dispute')),
                ),
                const Spacer(),
                SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Contact Organizer')),
                ),
              ],
            ),
          ),
        )
      ])),
    );
  }
}

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

enum ChatRoomType { individual, business }

class ChatsView extends StatelessWidget {
  const ChatsView({super.key, required this.chatType});

  final ChatRoomType chatType;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatData.length,
      itemBuilder: (BuildContext context, int index) {
        final chat = chatData[index];
        return ListTile(
          leading: const Icon(Icons.park),
          title: Text(
            chat.senderName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          subtitle: Text(
            chat.messages.isNotEmpty
                ? chat.messages.last.senderName == 'You'
                    ? 'You: ${chat.messages.last.content}'
                    : chat.messages.last.content
                : '',
          ),
          trailing: Text(
              chat.messages.isNotEmpty ? chat.messages.last.time : '',
              style: const TextStyle(fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                    chat: chat, chatType: ChatRoomType.individual),
              ),
            );
          },
        );
      },
    );
  }
}

class ConversationScreen extends StatefulWidget {
  final Chat chat;
  final ChatRoomType chatType;

  ConversationScreen({required this.chat, required this.chatType});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = TextEditingController();
  final Chat test = Chat(
      senderName: 'Business',
      chatType: ChatRoomType.individual,
      senderImage: 'assets/images/david_johnson_avatar.jpg',
      messages: [
        Message(
          senderName: 'You',
          content: 'How is everything going',
          time: 'Yesterday',
        ),
        Message(
          senderName: 'David Johnson',
          content: 'Everything is cool over here',
          time: 'Yesterday',
        ),
        Message(
          senderName: 'Moses Mbuva',
          content: 'Want to go grab a drink?',
          time: 'Yesterday',
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.senderName), actions: [
        IconButton(icon: const Icon(Icons.account_circle), onPressed: () {})
      ]),
      body: SafeArea(
        child: test.chatType == ChatRoomType.individual
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: test.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final isUser =
                      widget.chat.messages[index].senderName == 'You';
                  final message = widget.chat.messages[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: const Icon(Icons.park),
                    tileColor: isUser
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.25)
                        : null,
                    title: Text(
                      message.senderName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    subtitle: Text(message.content),
                    trailing: Text(message.time,
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              )
            : Column(
                children: [
                  Container(
                    height: 150,
                    width: width(context),
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to ${widget.chat.senderName}\'s Chatroom',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 20),
                        const Text(
                          'This is where people get to talk and inform each other '
                          'about what is going on at your business place. All messages '
                          'expire after 24 hours.',
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                      child: SizedBox(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.chat.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final isUser =
                            widget.chat.messages[index].senderName == 'You';
                        final message = widget.chat.messages[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: const Icon(Icons.park),
                          tileColor: isUser
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.25)
                              : null,
                          title: Text(
                            message.senderName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          subtitle: Text(message.content),
                          trailing: Text(message.time,
                              style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  )),
                ],
              ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 10,
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Send a message...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  final content = messageController.text;
                  final time = DateFormat.jm().format(DateTime.now());
                  widget.chat.messages.add(
                      Message(content: content, time: time, senderName: 'You'));
                  messageController.clear();
                });
              },
              icon: Icon(Icons.send,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  final String senderName;
  final String senderImage;
  final ChatRoomType chatType;
  final List<Message> messages;

  Chat({
    required this.senderName,
    required this.senderImage,
    required this.messages,
    required this.chatType,
  });
}

class Message {
  final String senderName;
  final String content;
  final String time;

  Message({
    required this.senderName,
    required this.content,
    required this.time,
  });
}

// Sample chat data
final List<Chat> chatData = [
  Chat(
    senderName: 'John Doe',
    senderImage: 'assets/images/john_doe_avatar.jpg',
    chatType: ChatRoomType.individual,
    messages: [
      Message(
        senderName: 'John Doe',
        content: 'Hello, how are you?',
        time: '10:30 AM',
      ),
      Message(
        senderName: 'You',
        content: 'I\'m good, thanks! How about you?',
        time: '10:35 AM',
      ),
    ],
  ),
  Chat(
    senderName: 'Jane Smith',
    senderImage: 'assets/images/jane_smith_avatar.jpg',
    chatType: ChatRoomType.individual,
    messages: [
      Message(
        senderName: 'Jane Smith',
        content: 'I will be there soon.',
        time: '9:45 AM',
      ),
      Message(
        senderName: 'You',
        content: 'Great, see you soon!',
        time: '9:50 AM',
      ),
    ],
  ),
  Chat(
    senderName: 'David Johnson',
    chatType: ChatRoomType.individual,
    senderImage: 'assets/images/david_johnson_avatar.jpg',
    messages: [
      Message(
        senderName: 'You',
        content: 'Can you please send me the document?',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'David Johnson',
        content: 'Sure, I will send it to you shortly.',
        time: 'Yesterday',
      ),
    ],
  ),
  Chat(
    senderName: 'Business',
    chatType: ChatRoomType.business,
    senderImage: 'assets/images/david_johnson_avatar.jpg',
    messages: [
      Message(
        senderName: 'You',
        content: 'How is everything going',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'David Johnson',
        content: 'Everything is cool over here',
        time: 'Yesterday',
      ),
      Message(
        senderName: 'Moses Mbuva',
        content: 'Want to go grab a drink?',
        time: 'Yesterday',
      ),
    ],
  ),
];

class Place extends StatelessWidget {
  const Place({super.key, this.placeName, this.category});

  final String? placeName;
  final String? category;

  void _shareOnFacebook() {
    Share.share('Shared on Facebook');
  }

  void _shareOnTwitter() {
    Share.share('Shared on Twitter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.placeName ?? 'Null'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share on social media'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.facebook),
                          title: const Text('Share on Facebook'),
                          onTap: () {
                            // Implement Facebook sharing logic here
                            _shareOnFacebook();
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.twitter),
                          title: const Text('Share on Twitter'),
                          onTap: () {
                            // Implement Twitter sharing logic here
                            _shareOnTwitter();
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        // Add more social media sharing options as needed
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                    Text(this.placeName ?? 'Null',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    Chip(label: Text(this.category ?? 'Null')),
                    const Text('Open - 08:00 AM to 08:00 PM'),
                    const SizedBox(height: 5),
                    const Text('Popularity: 95%',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
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
                              child: const Text('Follow',
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
                              child: const Text('Chat Room',
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
                              child: const Text('Contact',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text('About ' + (this.placeName ?? 'Null'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    const SizedBox(height: 10),
                    const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing '
                        'elit. Praesent porta, libero at ultricies '
                        'lacinia, diam sapien lacinia mi, quis aliquet '
                        'diam ex et massa. Sed a tellus ac tortor '
                        'placerat rutrum in non nunc.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceOrder(
                                orderType: OrderType.service,
                                orderTitle: this.placeName ?? ''),
                          ),
                        );
                      },
                      child: const Text('Check out our services'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Street Name', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: width(context),
                height: 100,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Photos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                        height: 20,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            onPressed: () {},
                            child: const Text('See more',
                                style: TextStyle(fontSize: 12)))),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                width: width(context),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        width: width(context) * 0.25,
                        color: Colors.grey,
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

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

class PatroneDashboard extends StatefulWidget {
  const PatroneDashboard({super.key});

  @override
  State<PatroneDashboard> createState() => _PatroneDashboardState();
}

class _PatroneDashboardState extends State<PatroneDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _exploreController;
  String? selectedReason;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _exploreController = TabController(length: 2, vsync: this);
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
                          items: [
                            const DropdownMenuItem(
                              value: 'Spam',
                              child: Text('Spam'),
                            ),
                            const DropdownMenuItem(
                              value: 'Harassment',
                              child: Text('Harassment'),
                            ),
                            const DropdownMenuItem(
                              value: 'Inappropriate Content',
                              child: Text('Inappropriate Content'),
                            ),
                            const DropdownMenuItem(
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
                    ]));
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
                    ]));
      }
    });
  }

  Widget? trailingIcon() {
    switch (_currentIndex) {
      case 0:
        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadImage(),
              ),
            );
          },
          icon: const Icon(Icons.photo_camera),
        );
      case 1:
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        );
      case 3:
        return PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'Settings') {
              Navigator.pushNamed(context, 'settings');
            } else if (value == 'Order') {
              Navigator.pushNamed(context, 'orders');
            } else if (value == 'Igniter') {
              Navigator.pushNamed(context, 'igniter_dashboard');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'Order',
              child: Text('Orders'),
            ),
            const PopupMenuItem<String>(
              value: 'Igniter',
              child: Text('Switch to Igniter Profile'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        );
    }
    return null;
  }

  Widget? titleWidget(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const Text('WazzLitt! around me');
      case 1:
        return TabBar(
          unselectedLabelStyle:
              TextStyle(color: Theme.of(context).colorScheme.primary),
          indicatorColor: Theme.of(context).colorScheme.primary,
          controller: _exploreController,
          tabs: [const Tab(text: 'Lit'), const Tab(text: 'Places')],
        );
      case 2:
        return const Text('Messages');
      case 3:
        return const Text('Profile');
    }
    return null;
  }

  List<Widget> views(BuildContext context) {
    return [
      feed(context),
      explore(context),
      const ChatsView(chatType: ChatRoomType.individual),
      const ProfileScreen(),
    ];
  }

  String _selectedChip = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget(context),
        actions: [
          trailingIcon() ?? const SizedBox(),
        ],
      ),
      body: views(context)[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Theme.of(context).colorScheme.primary,
        ),
        child: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: 'Explore', icon: Icon(Icons.explore)),
            BottomNavigationBarItem(label: 'Messages', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                label: 'Profile', icon: Icon(Icons.account_circle)),
          ],
        ),
      ),
    );
  }

  Widget explore(BuildContext context) {
    return Column(
      children: [
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
        Expanded(
          child: TabBarView(
            controller: _exploreController,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: width(context) * 0.5,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: width(context) * 0.5,
                            width: width(context) * 0.5,
                            color: Colors.indigo,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event $index',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Description $index',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Text('Upcoming Events',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: SizedBox(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () => {
                              showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.park, size: 80),
                                      const SizedBox(height: 10),
                                      Text('Event $index',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index location',
                                      ),
                                      const Text('0 km away',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index date',
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Event $index price',
                                      ),
                                      const Text('Original price',
                                          style: TextStyle(
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: width(context),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlaceOrder(
                                                          orderType:
                                                              OrderType.event,
                                                          orderTitle:
                                                              'Event $index'),
                                                ),
                                              );
                                            },
                                            child: const Text('Buy Tickets')),
                                      ),
                                      const SizedBox(height: 30),
                                      Text('About Event $index',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      const Text(
                                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent porta, libero at ultricies lacinia, diam sapien lacinia mi, quis aliquet diam ex et massa. Sed a tellus ac tortor placerat rutrum in non nunc. Mauris porttitor dapibus neque, at efficitur erat hendrerit nec. Cras mollis volutpat eros, vestibulum accumsan arcu rutrum a.'),
                                      const SizedBox(height: 10),
                                      const Chip(label: Text('Category')),
                                      const SizedBox(height: 10),
                                      const Text('Organizer',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      ListTile(
                                        leading: const Icon(Icons.park),
                                        title: const Text('Organizer name'),
                                        subtitle: const Text('Category'),
                                        trailing: TextButton(
                                            onPressed: () {},
                                            child: const Text('Follow')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            },
                            leading: const Icon(Icons.park),
                            title: Text('Event $index',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: const Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text('01/01/1980',
                                    style: TextStyle(fontSize: 14)),
                                Text('\$0.00', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(categories[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 20,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(0)),
                                onPressed: () {},
                                child: const Text('See more',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: width(context),
                              height: 190,
                              child: ListView.builder(
                                itemCount: 3,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Place(
                                                placeName: 'Place $i',
                                                category: categories[index]))),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: width(context) / 3,
                                          width: width(context) / 3,
                                          color: Colors.indigo,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              'Place $i',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // SizedBox(height: ),
                                            const Text(
                                              '0 km away',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Nearby Places',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Flexible(
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.place),
                          title: Text('Place $index',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Wrap(
                            direction: Axis.vertical,
                            children: [
                              Text('Location', style: TextStyle(fontSize: 14)),
                              Text('0 km away', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Column feed(BuildContext context) {
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
}

class IgniterProfile extends StatefulWidget {
  IgniterProfile({super.key});

  @override
  State<IgniterProfile> createState() => _IgniterProfileState();
}

class _IgniterProfileState extends State<IgniterProfile> {
  File? _coverPhoto;
  File? _profilePicture;
  String _selectedChip = '';

  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _coverPhoto = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profilePicture = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Igniter Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: width(context),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickCoverPhoto(); // Function to handle cover photo selection
                    },
                    child: Container(
                      width: width(context),
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      child: _coverPhoto != null
                          ? Image.file(
                              _coverPhoto!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.add_photo_alternate),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        _pickProfilePicture(); // Function to handle profile picture selection
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          shape: BoxShape.circle,
                        ),
                        child: _profilePicture != null
                            ? Image.file(
                                _profilePicture!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 8,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: height(context) * 0.5,
                  width: width(context),
                  child: ListView(children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.name),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    Text(AppLocalizations.of(context)!.selectCategory,
                        style: const TextStyle(fontSize: 12)),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories
                            .map(
                              (chip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
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
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.website),
                      keyboardType: TextInputType.url,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    TextFormField(
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.description),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const Padding(padding: EdgeInsets.only(top: 15)),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ])),
            ),
            const Spacer(),
            SizedBox(
              width: width(context) * 0.8,
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.createIgniter,
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.igniterTrial,
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, 'patrone_dashboard'),
                        child: Text(AppLocalizations.of(context)!.proceed),
                      ),
                    ],
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class IgniterRegistration extends StatelessWidget {
  const IgniterRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.createIgniter,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.profileType,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'igniter_profile'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-1.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.eventOrganizer,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.eventOrganizerDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'igniter_profile'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-2.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.businessOwner,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.businessOwnerDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, 'igniter_profile'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: width(context),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/igniter-3.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.individual,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.individualDescription,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Interests extends StatelessWidget {
  const Interests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.chooseInterests,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Text(AppLocalizations.of(context)!.interestsSubtitle,
                  textAlign: TextAlign.center),
              const Spacer(),
              SizedBox(
                width: width(context),
                height: height(context) * 0.5,
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per column
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    bool isChecked;
                    isChecked = true;
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/igniter-1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 20,
                                // ignore: dead_code
                                color: isChecked ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, 'igniter_registration'),
                      child: Text(AppLocalizations.of(context)!.proceed)))
            ],
          ),
        ),
      ),
    );
  }
}

List<String> categories = ['Ratchet', 'Free Spirit', 'Classy', 'Rock', 'Afro'];

class PatroneRegistration extends StatelessWidget {
  PatroneRegistration({super.key});
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.createPatrone,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.accountDetails,
              ),
              const Spacer(),
              Expanded(
                flex: 12,
                child: SizedBox(
                  width: width(context),
                  height: height(context) * 0.5,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.fname,
                          ),
                          autofillHints: const [AutofillHints.name],
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.lname,
                          ),
                          autofillHints: const [AutofillHints.name],
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.username,
                          ),
                          autofillHints: const [AutofillHints.newUsername],
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email,
                          ),
                          autofillHints: const [AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: dobController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.dob,
                            suffixIcon: const Icon(Icons.calendar_month),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              dobController.text = selectedDate.toString();
                            }
                          },
                          autofillHints: const [AutofillHints.birthday],
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                          ),
                          autofillHints: const [AutofillHints.newPassword],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: width(context),
                child: ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.create),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.createPatrone,
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.patroneTrial,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.popAndPushNamed(context, 'interests'),
                          child: Text(AppLocalizations.of(context)!.proceed),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.verifyPhone,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              TextFormField(
                maxLength: 9,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phone,
                    border: InputBorder.none),
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              SizedBox(
                  width: width(context),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, 'patrone_registration'),
                    child: Text(
                      AppLocalizations.of(context)!.proceed,
                    ),
                  )),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.googleSignIn,
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.google),
                onPressed: () {},
              ),
              const Spacer(flex: 2),
              Text(
                AppLocalizations.of(context)!.acceptTerms,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/home-image.png',
              )),
        ),
        height: height(context),
        width: width(context),
        child: Column(
          children: [
            const Spacer(
              flex: 20,
            ),
            Text(
              AppLocalizations.of(context)!.homeTitle,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: width(context),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'signup'),
                child: Text(
                  AppLocalizations.of(context)!.patrone,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: width(context),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'signup'),
                child: Text(
                  AppLocalizations.of(context)!.igniter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double height(context) {
  return MediaQuery.of(context).size.height;
}

double width(context) {
  return MediaQuery.of(context).size.width;
}
