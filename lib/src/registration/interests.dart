import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wazzlitt/authorization/authorization.dart';
import '../app.dart';
import '../../user_data/patrone_data.dart';

class Interests extends StatefulWidget {
  const Interests({super.key});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
  List<Category> categories = [];
  @override
  void initState() {
    super.initState();
    if (!isLoggedIn()) {
      Navigator.popAndPushNamed(context, 'home');
    }
  }

  List<Category> selectedCategories = [];

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
                    final categoryItem = categories[index];
                    final isSelected =
                        selectedCategories.contains(categoryItem);
                    return GridTile(
                      child: GestureDetector(
                        onTap: () => toggleCategorySelection(categoryItem),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              colorFilter: isSelected
                                  ? null
                                  : const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.saturation,
                                    ),
                              image: NetworkImage(categoryItem.imageLink!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              categoryItem.display!,
                              style: TextStyle(
                                  fontSize: isSelected ? 20 : 16,
                                  // ignore: dead_code
                                  color: Colors.white,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : null),
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
                      onPressed: () {
                        if (selectedCategories.length < 3) {
                          showSnackbar(context,
                              'Please select at least 3 categories to proceed');
                        } else {
                          Patrone()
                              .saveUserInterests(interests: selectedCategories)
                              .then((value) => Navigator.pushNamed(
                                  context, 'patrone_dashboard'));
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.proceed)))
            ],
          ),
        ),
      ),
    );
  }

  void toggleCategorySelection(Category categoryItem) {
    if (selectedCategories.contains(categoryItem)) {
      setState(() {
        selectedCategories.remove(categoryItem);
      });
    } else {
      setState(() {
        selectedCategories.add(categoryItem);
      });
    }
  }
}

class Category {
  final String? display;
  final String? imageLink;

  Category({this.display, this.imageLink});

  List<Category> categories = [
    Category(
      display: 'Afro',
      imageLink:
          'https://i.pinimg.com/564x/79/45/69/794569fd9485b2094c2e99e524b65d55.jpg',
    ),
    Category(
      display: 'Classy',
      imageLink:
          'https://i.pinimg.com/564x/c5/78/02/c578020e1952e4529ea2e9c0ddc4f6fd.jpg',
    ),
    Category(
      display: 'Free Spirit',
      imageLink:
          'https://i.pinimg.com/564x/c4/8f/79/c48f79162a0139393482af86ca088dfe.jpg',
    ),
    Category(
      display: 'Hood',
      imageLink:
          'https://i.pinimg.com/564x/c4/2b/2d/c42b2dd945e5a30904bde4d0202474a0.jpg',
    ),
    Category(
      display: 'Latin',
      imageLink:
          'https://i.pinimg.com/564x/f2/ba/9e/f2ba9e2dcd225dd0af284b661319f214.jpg',
    ),
    Category(
      display: 'Pride',
      imageLink:
          'https://i.pinimg.com/564x/66/e1/04/66e104f2b45f52ded214307d6ed0dcba.jpg',
    ),
    Category(
      display: 'Ratchet',
      imageLink:
          'https://i.pinimg.com/564x/28/f9/91/28f9914e508ecbbf7113dd427c4ff8c3.jpg',
    ),
  ];
}
