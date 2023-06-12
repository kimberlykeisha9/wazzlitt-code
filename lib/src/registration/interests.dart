import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app.dart';

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
                          Navigator.pushNamed(context, 'patrone_dashboard'),
                      child: Text(AppLocalizations.of(context)!.proceed)))
            ],
          ),
        ),
      ),
    );
  }
}