
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../model/PartsViewModel.dart';
import '../model/adIdManagement.dart';
import '../model/colorList.dart';

class ColorSelectPage extends StatefulWidget {
  final int? editColorId;
  final int? rouletteId;

  const ColorSelectPage({Key? key, this.editColorId,this.rouletteId}) : super(key: key);

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  //広告用
  // バナー広告をインスタンス化
  final BannerAd myBanner = BannerAd(
    adUnitId: AdIdManagement.colorSelectBannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  final _colorSelectList= ColorList().colorSelectList;


//  int _rouletteId =0;

  List<Map<String, dynamic>> _parts = [];
  bool _isLoading = true; //画面更新グルグルに使う判定値

  List<int> _usedColorsList = [];

  //使用している色を取得

  Future<void> _refreshJournals() async {
    //データベースの一覧をパーツに登録。画面更新用
    final data = await PartsViewModel.getNotes(widget.rouletteId ?? 0);
    setState(() {
      _parts = data;
      _isLoading = false;
    });
  }

  Future<void> _updateColor(int id, int color) async {
    await PartsViewModel.updateColor(id, color);
    await _refreshJournals();
    _addUsedColors();
  }

  _addUsedColors() {
    _usedColorsList = [];
    for (var i = 0; i < _parts.length; i++) {
      _usedColorsList.add(_parts[i]['color']);
    }
  }

  _usedColorChack(index) {
    if (_parts[widget.editColorId ?? 99]['color'] == index) {
      return 1.0;
    } else if (_usedColorsList.contains(index)) {
      return 0.1;
    } else {
      return 0.0;
    }
  }

  @override
  void initState() {
    //画面構築時

    Future(() async {
      await _refreshJournals();
      _addUsedColors();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // バナー広告の読み込み
    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );


//    final colorList = ColorList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('色選択'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: GridView.count(
                crossAxisCount: 4,
                children: List.generate(
                    _colorSelectList.length,
                    (index) => Card(
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  color: _colorSelectList[index],
                                ),
                                Center(
                                    child: Opacity(
//                            opacity:0.5,
                                  opacity: _usedColorChack(index),
                                  child: const Icon(
                                    Icons.check,
                                    size: 48,
                                  ),
                                )),
                                FractionallySizedBox(
                                  widthFactor: 1.0,
                                  heightFactor: 1.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _updateColor(
                                          _parts[widget.editColorId ?? 1]['id'],
                                          index);
                                      // int.parse(
                                      //     _ratioController[index].text));

                                      Navigator.pop(context, true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        elevation: 0,
                                        onPrimary: Colors.black45),
                                    child: const Text(''),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
              ),
            ),
    );
  }
}
