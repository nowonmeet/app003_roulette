import 'package:app003_roulette/colorFile.dart';
import 'package:app003_roulette/model/applocalizations.dart';
import 'package:app003_roulette/pages/language_selection_page.dart';
import 'package:app003_roulette/pages/roulettePage.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main()  {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  MobileAds.instance.initialize();

  runApp( MyApp());



}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  bool _isFirstTime = false;
//    late bool _isFirstTime;
  var _languageCode = 'en'; //言語設定用

  var appLocalizations = AppLocalizations();//多言語対応用


  @override
  void initState() {
    super.initState();

    Future(() async {
      await _checkFirstTime();
    });


  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      _languageCode = prefs.getString('languageCode') ?? 'en';
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //アプリ一覧画面起動時のタイトル
      title: appLocalizations.getTranslatedValue(_languageCode,'title'),
      theme: ThemeData(
         primarySwatch: OlignalColor.primaryColor,
      ),
      home: _isFirstTime
          ? const LanguageSelectionPage()
            : RoulettePage(languageCode: _languageCode)


      //     ? LanguageSelectionPage(
      //   onItemSelected: (index) {
      //     _updateSelectedLanguageCode(index);
      //     Navigator.of(context).pushReplacement(
      //       MaterialPageRoute(builder: (context) => RoulettePage(languageCode: _languageCode)),
      //     );
      //   },
      // )

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

//記述の順番
//1.インポートの記述
//2.クラスの定義
//3.フィールドの宣言
//4.initStateメソッド
//5.ビルドメソッド
//6.ヘルパーメソッド
//7.ウィジェットのライフサイクルイベントメソッド
//8.コールバックメソッド
//9.disposeメソッド