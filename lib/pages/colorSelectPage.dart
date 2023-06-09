
import 'package:app003_roulette/model/applocalizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/PartsViewModel.dart';
import '../model/colorList.dart';

class ColorSelectPage extends StatefulWidget {
  final int? editColorId; //編集時の色ID
  final int? rouletteId;  //ルーレットID
  const ColorSelectPage({Key? key, this.editColorId,this.rouletteId}) : super(key: key);

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}
class _ColorSelectPageState extends State<ColorSelectPage> {


  var appLocalizations = AppLocalizations();//多言語対応用
  var _languageCode = 'en'; //言語設定用
  final _colorSelectList= ColorList().colorSelectList;  //色一覧
  List<Map<String, dynamic>> _parts = []; //データベースの一覧をパーツに登録。画面更新用
  bool _isLoading = true; //画面更新グルグルに使う判定値
  List<int> _usedColorsList = []; //使用済みの色を格納するリスト

  @override
  void initState() {
    //画面構築時

    Future(() async {
      await _refreshJournals(); //データベースの一覧をパーツに登録。画面更新用
      await _getLanguage(); //言語設定を取得
      _addUsedColors(); //使用済みの色を格納するリスト
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(appLocalizations.getTranslatedValue(_languageCode,'colorTitle')),
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
                    (index) => Card(//色選択ボタン
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                Container(//色選択ボタン
                                  //角丸にする
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _colorSelectList[index],
                                  ),
                                ),
                                Center(//色選択ボタンの上にチェックマーク
                                    child: Opacity(
//                            opacity:0.5,
                                  opacity: _usedColorCheck(index),
                                  child: const Icon(
                                    Icons.check,
                                    size: 48,
                                  ),
                                )),
                                FractionallySizedBox(//色選択ボタンの上に透明ボタン
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
                                    style: ElevatedButton.styleFrom(//透明ボタンのスタイル
                                        foregroundColor: Colors.black45,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0),
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



  _getLanguage() async {//言語設定を取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('languageCode') ?? 'ja';
    });
  }




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

  _usedColorCheck(index) {
    if (_parts[widget.editColorId ?? 99]['color'] == index) {
      return 1.0;
    } else if (_usedColorsList.contains(index)) {
      return 0.1;
    } else {
      return 0.0;
    }
  }


}
