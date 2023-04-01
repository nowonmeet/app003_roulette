
import 'package:app003_roulette/model/applocalizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/PartsViewModel.dart';
import '../model/colorList.dart';

class ColorSelectPage extends StatefulWidget {
  final int? editColorId;
  final int? rouletteId;

  const ColorSelectPage({Key? key, this.editColorId,this.rouletteId}) : super(key: key);

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {


  var appLocalizations = AppLocalizations();//多言語対応用
  var _languageCode = 'en'; //言語設定用

  _getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('languageCode') ?? 'ja';
    });
  }

  final _colorSelectList= ColorList().colorSelectList;


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
      await _getLanguage();
      _addUsedColors();

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
}
