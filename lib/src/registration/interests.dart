import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app.dart';

class Interests extends StatefulWidget {
  const Interests({super.key});

  @override
  State<Interests> createState() => _InterestsState();
}

class _InterestsState extends State<Interests> {
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
                    bool isSelected = _selectedCategories.contains(categories[index]);
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          if (_selectedCategories.contains(categories[index])) {
                            setState(() {
                              _selectedCategories.remove(categories[index]);
                            });
                          } else if (!_selectedCategories.contains(categories[index])) {
                            setState(() {
                              _selectedCategories.add(categories[index]);
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              colorFilter: isSelected ? null : const ColorFilter.mode(Colors.white, BlendMode.saturation),
                              image: const AssetImage('assets/images/igniter-1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16,
                                // ignore: dead_code
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : null
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
                      onPressed: () {
                        if(_selectedCategories.length < 3) {
                          showSnackbar(context, 'Please select at least 3 categories to proceed');
                        } else {
                          Navigator.pushNamed(context, 'patrone_dashboard');
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.proceed)))
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _selectedCategories = [];