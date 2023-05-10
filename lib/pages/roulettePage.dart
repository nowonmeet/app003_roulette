import 'dart:math';

import 'package:app003_roulette/model/adIdManagement.dart';
import 'package:app003_roulette/model/colorList.dart';
import 'package:app003_roulette/pages/language_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:roulette/roulette.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/PartsViewModel.dart';
import '../model/RouletteViewModel.dart';
import '../model/applocalizations.dart';
import '../model/contact_form.dart';
import 'addEditPage.dart';
import 'listPage.dart';

class RoulettePage extends StatefulWidget {
  final String languageCode;
  const RoulettePage({Key? key, required this.languageCode}) : super(key: key);

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with TickerProviderStateMixin //アニメーションが２つ以上
//    with SingleTickerProviderStateMixin //アニメーションが一つだけの場合
{


  //変数の初期設定ゾーン
  late RouletteController _controller;
  late RouletteGroup _group;
  bool _isLoading = true; //画面更新グルグルに使う判定値
  bool _titleIsLoading = true;
  late String _rouletteTitle;
  late bool _isFirstTime; //初回起動かどうか
  late bool _isLanguageSelected;  //言語が選択されているかどうか
  late bool _isEmptyRoulette; //ルーレットが空かどうか
  List<Map<String, dynamic>> _parts = [];//項目のリスト
  List<int> _ratioList = [];//比率のリスト
  int _rouletteId = 0;
  final _colorSelectList= ColorList().colorSelectList;//色のリストを読み込む
  final bool _clockwise = true;//時計回りかどうか
  var random = math.Random(); //ランダムを生成
  var _resultNumber = 0; //結果選択用
  var _rouletteResult = ''; //結果表示用
  var _languageCode = 'en'; //言語設定用
  var appLocalizations = AppLocalizations();

  @override
  void initState() {
    //画面構築時
    Future(() async {
      await _firstStartup();  //初回起動時の処理
      await _getRouletteId(); //ルーレットIDを取得
      await _getTitle(_rouletteId); //ルーレットタイトルを取得
      await _reloadRoulette();  //ルーレットを再読み込み
      await _getLanguage(); //言語設定を取得
    });
    super.initState();
    _rouletteResult = ''; //結果表示用

  }


  @override
  Widget build(BuildContext context) {
    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    //AddEditPageへの遷移と、帰ってきた時の処理
    WidgetsFlutterBinding.ensureInitialized();

    return WillPopScope(
      onWillPop: () async  => false,
        //戻るボタンを押した時の処理
//return true; // 画面を閉じる
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          backgroundColor: Colors.white,
          title: _titleIsLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Text(_rouletteTitle),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
               DrawerHeader(
                  decoration: const BoxDecoration(
                      image:
                          DecorationImage(
                            fit: BoxFit.fitHeight,
                              image: AssetImage('lib/assets/drawer.png')
                          )),
                  child: Text(
                    appLocalizations.getTranslatedValue(_languageCode,'menu'),
                  ),
              ),
              ListTile(
                title:  Text(
                    appLocalizations.getTranslatedValue(_languageCode,'privacy_policy'),
),
                leading: const Icon(Icons.vpn_key),
                onTap: () {
                  _privacyPolicyURL();
                  Navigator.pop(context); //Drawerを閉じる
                },
              ),
              ContactForm(languageCode: _languageCode),

              ListTile(
                title:  Text(
                  appLocalizations.getTranslatedValue(_languageCode,'languageSelect'),
                ),
                leading: const Icon(Icons.language),
                onTap: () {
                  //LanguageSelectionPageに移動する。
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectionPage(),
                    ),
                  );


                },
              ),

            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _rouletteResult = '';
                            pushWithReloadByReturnListPage(context);
                          },
                          icon: Image.asset('lib/assets/menu_icon.png'),
                          iconSize: 48,
                        ),
                        IconButton(
                          onPressed: () {
                            _rouletteResult = '';
                            pushWithReloadByReturnAddEditPage(context);
                          },
                          icon: const Icon(Icons.edit),
                          iconSize: 48,
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                      child: Row(
                        children: [
                           Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                            child: Text(
                              appLocalizations.getTranslatedValue(_languageCode,'result'),

                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Text(
                            _rouletteResult,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    Stack(alignment: Alignment.topCenter, children: [
                      Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Roulette(
                          controller: _controller,
                          style: const RouletteStyle(
                            dividerThickness: 2, //区切り線の幅
                            centerStickSizePercent: 0.3, //真ん中の円の割合
                            centerStickerColor: Colors.white, //真ん中の円の色
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 30,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.grey, width: 1),
                              elevation: 10,
                              shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(double.infinity),
                                    bottomLeft: Radius.circular(double.infinity)),
                              ),
                            ),
                            child: const Text(''),
                          ),
                        ),
                      ),
                    ]),
                    // Text(_parts.toString()),
                    // Text(_ratioList.toString()),
                    Expanded(child: Container()),

                    adContainer,


                  ],
                ),
              ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 48.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () async {
              _displayReset(); //結果表示をリセット
              _resultNumber = getRandomIndex(_ratioList);
              await _controller.rollTo(
                //結果の選択（ランダムで選択）
                _resultNumber,
                clockwise: _clockwise,
                offset: Random().nextDouble(), //項目内のずれ。1以上にすると別の項目に止まる
              );

              _resultDisplay();
            },
            child: const Icon(Icons.refresh_rounded),
          ),
        ),
      ),
    );
  }



  //広告用
  // バナー広告をインスタンス化
  final BannerAd myBanner = BannerAd(
    adUnitId: AdIdManagement.rouletteBannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  _getRouletteId() async {//保存しているルーレットIDを取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rouletteId = prefs.getInt('rouletteId') ?? 1;
    });
  }

  // Shared PreferenceにIDを書き込む
  void _setRouletteId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 以下の「counter」がキー名。
    await prefs.setInt('rouletteId', _rouletteId);
  }

  Future<void> _getTitle(rouletteId) async {
    //SQLからタイトルを取得
    final data = await RouletteViewModel.getItem(rouletteId);
    if (data.isNotEmpty) {
      setState(() {
        _rouletteTitle = data[0]['name'];
        _titleIsLoading = false;
      });
    }
  }

  _getLanguage() async {  //言語設定を取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('languageCode') ?? 'en';
    });
  }

  Future<void> _refreshJournals() async {
    //データベースの一覧をパーツに登録。画面更新用
    //ルーレットグループの設定も行う。
    final data = await PartsViewModel.getNotes(_rouletteId);
    setState(() {
      _parts = data;
      _isLoading = false;
      _group = RouletteGroup([
        for (var i = 0; i < _parts.length; i++)
          RouletteUnit.text(_parts[i]['name'],
              color: _colorSelectList[_parts[i]['color']],
              weight: _parts[i]['ratio'] / 10, //見た目の比率
              textStyle: const TextStyle(
                fontSize: 14,
                shadows: <Shadow>[
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                  ),
                ],
              )),
      ]);
    });
  }

  //ルーレット更新用
  Future<void> _reloadRoulette() async {
    await _refreshJournals();
    _controller = RouletteController(
      group: _group,
      vsync: this,
    );
    _ratioList = [];
    for (var i = 0; i < _parts.length; i++) {
      _ratioList.add(_parts[i]['ratio']);
    }
  }

  //初回設定処理
  Future<void> _firstStartup() async {
    await _getIsLanguageSelected();
    if(_isLanguageSelected) {//言語が選択されている場合のみ実行
      //_addItemFirstStartup()が実行されているかどうかを取得する。
      await _getIsEmptyRoulette();
      //ルーレット作成ずみかどうか確認する
      if(_isEmptyRoulette) { //ルーレット作成していない時のみ実行
        //初回の設定処理
        await _addItemFirstStartup();
      }

      // await _getFirstStartup();
      // if (_isFirstTime) {
      //   //初回の設定処理
      //   await _addItemFirstStartup();
      // }
    }
  }

  //言語が選択されているかどうかを取得する。
  Future<void> _getIsLanguageSelected() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLanguageSelected = prefs.getBool('isLanguageSelected') ?? false;
    });
  }

  Future<void> _getFirstStartup() async { //初回起動かどうかを取得する。
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  Future<void> _getIsEmptyRoulette() async { //ルーレットが空かどうか判別する。
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEmptyRoulette = prefs.getBool('isEmptyRoulette') ?? true;
    });
  }

  Future<void> _addItemFirstStartup() async {//初回起動のみ自動でルーレットを作成する
    await RouletteViewModel.createItem(appLocalizations.getTranslatedValue(widget.languageCode,'dice'));
    await PartsViewModel.createItem(1, '１', 0, 1);
    await PartsViewModel.createItem(1, '２', 1, 1);
    await PartsViewModel.createItem(1, '３', 2, 1);
    await PartsViewModel.createItem(1, '４', 3, 1);
    await PartsViewModel.createItem(1, '５', 4, 1);
    await PartsViewModel.createItem(1, '６', 5, 1);
    _setIsEmptyRoulette();
  }

  // Shared PreferenceにIDを書き込む
  void _setIsEmptyRoulette() async {  //ルーレット作成したらfalseにする
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEmptyRoulette', false);
  }


  void _resultDisplay() { //結果表示
    setState(() {
      _rouletteResult = _parts[_resultNumber]['name'].toString();
    });
  }

  void _displayReset() {  //結果表示をリセット
    setState(() {
      _rouletteResult = '';
    });
  }

  int randomIntWithRange(int min, int max) {
    //min〜maxの間の数字のランダム
    int value = math.Random().nextInt(max - min);
    return value + min;
  }

  //渡された重み付け配列からIndexを得る テーブルは順番関係なし。
  getRandomIndex(List<int> inputTable) {
    List<int> weightTable = inputTable;
    int totalWeight = weightTable.reduce((a, b) => a + b);
    int value = randomIntWithRange(1, totalWeight + 1);

    int retIndex = -1;
    for (var i = 0; i < weightTable.length; ++i) {
      if (weightTable[i] >= value) {
        retIndex = i;
        break;
      }
      value -= weightTable[i];
    }
    return retIndex;
  }

  _privacyPolicyURL() async { //プライバシーポリシーに遷移

    String _privacyPolicyURLString = 'https://fir-memo-90c4e.web.app/';
    //言語に応じてURLを変更する。
    if(_languageCode == 'ja') {
      _privacyPolicyURLString = 'https://fir-memo-90c4e.web.app/';
    } else {
      _privacyPolicyURLString = 'https://service-agreement-now-on-meet.web.app/';
    }

    //プライバシーポリシーに遷移
    if (await canLaunchUrlString(_privacyPolicyURLString)) {  //URLを開けるかどうかチェック
      await launchUrlString(_privacyPolicyURLString);
    } else {
      throw 'Could not Launch $_privacyPolicyURLString';
    }
  }

  void pushWithReloadByReturnAddEditPage(BuildContext context) async {//追加・編集画面に遷移する
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AddEditPage(rouletteId: _rouletteId),
      ),
    );
    if (result == null) {
      //帰ってきた時にresultがtrueになる
    } else {
      if (result) {
        setState(() {
          _getTitle(_rouletteId);
          _reloadRoulette();
        });
      }
    }
  }

  void pushWithReloadByReturnListPage(BuildContext context) async { //リスト画面に遷移する
    final result = await Navigator.push(
      context,
      MaterialPageRoute<int>(
        builder: (BuildContext context) => ListPage(rouletteId: _rouletteId),
      ),
    );

    if (result == null) {
      //帰ってきた時にresultにルーレットIDが入る
    } else {
      _rouletteId = result;
    }
    setState(() {
      _setRouletteId();
      _getTitle(_rouletteId);
      _reloadRoulette();
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
