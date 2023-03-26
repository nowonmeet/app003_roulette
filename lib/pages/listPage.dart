import 'package:app003_roulette/model/PartsViewModel.dart';
import 'package:app003_roulette/model/RouletteViewModel.dart';
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

  //広告用
  // バナー広告をインスタンス化
  final BannerAd myBanner = BannerAd(
    adUnitId: AdIdManagement.listBannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );
  final _colorSelectList= ColorList().colorSelectList;


  _getCheckRouletteId() async {
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


  final int _rouletteId = 0;
  int _checkRouletteId = 0;

  List<Map<String, dynamic>> _roulettes = [];
  List<List<Map<String, dynamic>>> _roulettesAll = [];

  bool _isLoading = true; //画面更新グルグルに使う判定値
  bool _isDisabled = false; //ボタン連打防止用

  Future<void> _refreshJournals() async {
    //データベースの一覧をルーレットに登録。画面更新用
    final data = await RouletteViewModel.getNotes();
    setState(() {
      _roulettes = data;
    });
  }

  Future<void> _getRouletteAll() async {
    _roulettesAll = [];
    for (var i = 0; i < _roulettes.length; i++) {
      final data = await PartsViewModel.getNotes(_roulettes[i]['id']);
      _roulettesAll.add(data);
    }
    setState(() {
      _isLoading = false;
    });
  }


  _selectedRoulette(index) {
    if (_roulettes[index]['id'] == _rouletteId) {
      return Colors.black38;
    } else {
      return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await _refreshJournals();
      await _getRouletteAll();
      await _getCheckRouletteId();
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


    Future<void> _addItem() async {
      _isLoading = true;
      await RouletteViewModel.createItem('新しいルーレット');
//      await RouletteViewModel.createItem('name',DateTime.now());
      final date = await RouletteViewModel.getLatestItem();
      await PartsViewModel.createItem(date[0]['id'], '', 0, 1);
      await PartsViewModel.createItem(date[0]['id'], '', 1, 1);
      await _refreshJournals();
      await _getRouletteAll();
    }

    Future<void> _deleteItem(int id) async {
      _isLoading = true;
      await RouletteViewModel.deleteItem(id);
      await PartsViewModel.deleteRouletteItem(id);
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('Successfully deleted a journal!'),
      // ));
      await _refreshJournals();
      await _getRouletteAll();
      if(_checkRouletteId == id){
        _setRouletteId();
      }
    }

    _deleteAlertLast() {
      //最後の一個を削除時のアラート
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('注意'),
            content: const Text('ルーレットは1つ以上必要です。'),
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
          return AlertDialog(
            title: const Text('確認'),
            content: Text('${_roulettes[index]['name']} を削除しますか？',),
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

    return WillPopScope(
      //端末のバックボタンを無効にする
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('ルーレット一覧'),
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
                                  (index) => Card(
                                        shape: RoundedRectangleBorder(
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
                                                  Text(_roulettes[index]
                                                      ['name']),
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
                                                  Row(
                                                    children: [
                                                      IconButton(
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
                                                              Icons.delete))
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
                      const Duration(milliseconds: 500), //無効にする時間
                    );

                    setState(() => _isDisabled = false); //ボタンを有効
                  },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
