import 'package:app003_roulette/pages/roulettePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Selection'),
        backgroundColor: Colors.white,

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(

                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),

                onPressed: () async {
                  await setLocale('ja');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const RoulettePage(languageCode: 'ja',),
                    ),
                  );
                },

                child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('日本語'))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),

                onPressed: () async {
                  await setLocale('en');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const RoulettePage(languageCode: 'en',),
                    ),
                  );
                },
                child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('English'))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    await prefs.setBool('isFirstTime', false);
    await prefs.setBool('isLanguageSelected', true);
  }
}
