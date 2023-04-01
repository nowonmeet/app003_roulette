import 'package:app003_roulette/colorFile.dart';
import 'package:app003_roulette/pages/language_selection_page.dart';
import 'package:app003_roulette/pages/roulettePage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main()  {

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp( MyApp());



}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  bool _isFirstTime = true;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      _languageCode = prefs.getString('languageCode') ?? '';
    });
  }

  Future<void> _updateSelectedLanguageCode(String index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = index;
      prefs.setString('languageCode', _languageCode);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ルーレット',
      theme: ThemeData(
         primarySwatch: OlignalColor.primaryColor,
      ),
      home: _isFirstTime
          ? const LanguageSelectionPage()


      //     ? LanguageSelectionPage(
      //   onItemSelected: (index) {
      //     _updateSelectedLanguageCode(index);
      //     Navigator.of(context).pushReplacement(
      //       MaterialPageRoute(builder: (context) => RoulettePage(languageCode: _languageCode)),
      //     );
      //   },
      // )

          : RoulettePage(languageCode: _languageCode),
    );
  }
}

//todo 見た目を作る
//todo メイン
//todo 一覧
//todo 作成・編集
//     ルーレットのプレビュー
//todo 色の選択
//todo 設定
