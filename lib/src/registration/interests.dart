
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wazzlitt/user_data/user_data.dart';
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
    firestore.collection('app_data').doc('categories').get().then((value) {
      var data = value.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        var itemData = value as Map<String, dynamic>;
        String display = itemData['display'];
        String image = itemData['image'];
        setState(() {
          Category category = Category(display, image);
          categories.add(category);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<CategoryProvider>(builder: (context, categoryProvider, _) {
        return SafeArea(
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two items per column
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final categoryItem = categories[index];
                              final isSelected = categoryProvider
                                  .selectedCategories
                                  .contains(categoryItem);
                              return GridTile(
                                child: GestureDetector(
                                  onTap: () => categoryProvider
                                      .toggleCategorySelection(categoryItem),
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
                                        image: NetworkImage(
                                            categoryItem.imageLink),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        categoryItem.display,
                                        style: TextStyle(
                                            fontSize: isSelected ? 20 : 16,
                                            // ignore: dead_code
                                            color: Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : null),
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
                          if (categoryProvider.selectedCategories.length < 3) {
                            showSnackbar(context,
                                'Please select at least 3 categories to proceed');
                          } else {
                            Patrone().saveUserInterests(interests: categoryProvider
                                .selectedCategories).then((value) =>
                            Navigator.pushNamed(context, 'patrone_dashboard'));
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.proceed)))
              ],
            ),
          ),
        );
      }),
    );
  }
}

class Category {
  final String display;
  final String imageLink;

  const Category(this.display, this.imageLink);
}

class CategoryProvider extends ChangeNotifier {
  final List<Category> _selectedCategories = [];

  List<Category> get selectedCategories => _selectedCategories;

  void toggleCategorySelection(Category categoryItem) {
    if (_selectedCategories.contains(categoryItem)) {
      _selectedCategories.remove(categoryItem);
    } else {
      _selectedCategories.add(categoryItem);
    }
    notifyListeners();
  }
}

// Provider setup
ChangeNotifierProvider<CategoryProvider> categoryProvider =
    ChangeNotifierProvider<CategoryProvider>(
  create: (_) => CategoryProvider(),
);
