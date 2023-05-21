import 'package:app003_roulette/model/PartsViewModel.dart';
import 'package:app003_roulette/model/RouletteViewModel.dart';
import 'package:app003_roulette/model/applocalizations.dart';
import 'package:app003_roulette/pages/addEditPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/adIdManagement.dart';
import '../model/colorList.dart';

class ListPage extends StatefulWidget {
  final int? rouletteId;

  const ListPage({Key? key, this.rouletteId}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with TickerProviderStateMixin //アニメーションが２つ以上
{

  var appLocalizations = AppLocalizations();//多言語対応用
  var _languageCode = 'en'; //言語設定用
  final _colorSelectList= ColorList().colorSelectList;//色一覧
  final int _rouletteId = 0;
  int _checkRouletteId = 0;
  List<Map<String, dynamic>> _roulettes = []; //ルーレットのデータ
  List<List<Map<String, dynamic>>> _roulettesAll = [];  //ルーレットの全データ
  bool _isLoading = true; //画面更新グルグルに使う判定値
  bool _isDisabled = false; //ボタン連打防止用


  @override
  void initState() {
    super.initState();
    Future(() async {
      await _refreshJournals();
      await _getRouletteAll();
      await _getCheckRouletteId();
      await _getLanguage();
    });
  }




  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;

    // バナー広告の読み込み
    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    return WillPopScope(
      //端末のバックボタンを無効にする
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(appLocalizations.getTranslatedValue(_languageCode,'list')),
          automaticallyImplyLeading: false,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: _screenSize.height * 0.78,
                          child: GridView.count(
                            padding: const EdgeInsets.only(bottom: 60),
                              crossAxisCount: 2,
                              children: List.generate(
                                  _roulettes.length,
                                  (index) => Card(//ルーレットの枠
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                            color: _selectedRoulette(index),
                                          ),
                                        ),
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              FractionallySizedBox(
                                                widthFactor: 1.0,
                                                heightFactor: 0.8,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context,
                                                        _roulettes[index]
                                                            ['id']);
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    foregroundColor: Colors.black45,
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(''),
                                                ),
                                              ),
                                              Column(
                                                children: <Widget>[

                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Text(_roulettes[index]
                                                        ['name']),
                                                  ),
                                                  Expanded(
                                                    child:
                                                        FractionallySizedBox(
                                                      widthFactor: 1.0,
                                                      heightFactor: 0.6,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 40,
                                                                bottom: 40.0,
                                                                left: 40,
                                                                right: 40),
                                                        child: PieChart(
                                                          PieChartData(
                                                              sectionsSpace:
                                                                  1,
                                                              centerSpaceRadius:
                                                                  10,
                                                              centerSpaceColor:
                                                                  Colors
                                                                      .white,
                                                              startDegreeOffset:
                                                                  270,
                                                              sections: [
                                                                for (var i =
                                                                        0;
                                                                    i <
                                                                        _roulettesAll[index]
                                                                            .length;
                                                                    i++) ...{
                                                                  PieChartSectionData(
                                                                    color: _colorSelectList[_roulettesAll[index]
                                                                            [
                                                                            i]
                                                                        [
                                                                        'color']],
                                                                    value: _roulettesAll[index][i]
                                                                            [
                                                                            'ratio'] /
                                                                        10,
                                                                    radius:
                                                                        40,
                                                                    title: _roulettesAll[index]
                                                                            [
                                                                            i]
                                                                        [
                                                                        'name'],
                                                                    titleStyle:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                }
                                                              ]),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(//編集、削除ボタン
                                                    children: [
                                                      IconButton(//削除ボタン
                                                          onPressed: () {
                                                            if (_roulettes
                                                                    .length <=
                                                                1) {
                                                              _deleteAlertLast(); //アラートを表示
                                                            } else {
                                                              _deleteAlert(
                                                                  index);
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.delete)),
                                                      // const Expanded(child: SizedBox()),
                                                      // IconButton( //編集ボタン
                                                      //     onPressed: () {
                                                      //       pushWithReloadByReturnAddEditPage(context,index);
                                                      //     },
                                                      //     icon: const Icon(
                                                      //         Icons.edit)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                        ),
                      ),
                    ),

                    adContainer,

                  ],
                ),
              ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 48.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _isDisabled
                ? null
                : () async {
                    setState(() => _isDisabled = true); //ボタンを無効
                    await _addItem();

                    await Future.delayed(
                      const Duration(milliseconds: 1000), //無効にする時間
                    );

                    setState(() => _isDisabled = false); //ボタンを有効
                  },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  _deleteAlertLast() {
    //最後の一個を削除時のアラート
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(appLocalizations.getTranslatedValue(_languageCode,'attention')),
          content: Text(appLocalizations.getTranslatedValue(_languageCode,'rouletteAttention')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ))
          ],
        );
      },
    );
  }

  _deleteAlert(index) {
    //削除してもいいですか？はい/いいえ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog( // ダイアログの設定
          title: Text(appLocalizations.getTranslatedValue(_languageCode,'check')),
          content: Text(appLocalizations.getTranslatedValue(_languageCode,'deleteConfirmationMessage') + _roulettes[index]['name']),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                _deleteItem(_roulettes[index]['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  //広告用
  // バナー広告をインスタンス化
  final BannerAd myBanner = BannerAd(//広告用
    adUnitId: AdIdManagement.listBannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );



  _getLanguage() async {//Shared Preferenceから言語データを取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('languageCode') ?? 'ja';
    });
  }





  _getCheckRouletteId() async {//Shared PreferenceからルーレットIDデータを取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkRouletteId = prefs.getInt('rouletteId') ?? 1;
    });
  }

  // Shared Preferenceにデータを書き込む
  _setRouletteId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 以下の「counter」がキー名。
    await prefs.setInt('rouletteId', _roulettes[0]['id']);
  }


  Future<void> _refreshJournals() async {
    //データベースの一覧をルーレットに登録。画面更新用
    final data = await RouletteViewModel.getNotes();
    setState(() {
      _roulettes = data;
    });
  }

  Future<void> _getRouletteAll() async {  //データベースの一覧をルーレットに登録。画面更新用
    _roulettesAll = [];
    for (var i = 0; i < _roulettes.length; i++) {
      final data = await PartsViewModel.getNotes(_roulettes[i]['id']);
      _roulettesAll.add(data);
    }
    setState(() {
      _isLoading = false;
    });
  }


  _selectedRoulette(index) {//ルーレットを選択した時の処理
    if (_roulettes[index]['id'] == _rouletteId) {
      return Colors.black38;
    } else {
      return Colors.white;
    }
  }


  void pushWithReloadByReturnAddEditPage(BuildContext context,index) async {//追加・編集画面に遷移する
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => AddEditPage(rouletteId: _roulettes[index]['id']),
      ),
    );
    if (result == null) {
      //帰ってきた時にresultがtrueになる
    } else {
      if (result) {
        setState(() {
          _isLoading = true;
          _refreshJournals();
          _getRouletteAll();
        });
      }
    }
  }

  Future<void> _addItem() async { //ルーレット追加
    _isLoading = true;
    await RouletteViewModel.createItem(appLocalizations.getTranslatedValue(_languageCode,'newRoulette'));
//      await RouletteViewModel.createItem('name',DateTime.now());
    final date = await RouletteViewModel.getLatestItem();
    await PartsViewModel.createItem(date[0]['id'], '', 0, 1);
    await PartsViewModel.createItem(date[0]['id'], '', 1, 1);
    await _refreshJournals();
    await _getRouletteAll();
  }

  Future<void> _deleteItem(int id) async { //ルーレット削除
    _isLoading = true;
    await RouletteViewModel.deleteItem(id);
    await PartsViewModel.deleteRouletteItem(id);
    await _refreshJournals();
    await _getRouletteAll();
    if(_checkRouletteId == id){
      _setRouletteId();
    }
  }



}
