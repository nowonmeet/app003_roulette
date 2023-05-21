import 'dart:math' as math;
import 'package:app003_roulette/model/RouletteViewModel.dart';
import 'package:app003_roulette/model/applocalizations.dart';
import 'package:app003_roulette/pages/colorSelectPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/PartsViewModel.dart';
import '../model/adIdManagement.dart';
import '../model/colorList.dart';

class AddEditPage extends StatefulWidget {
  final int? rouletteId;

  const AddEditPage({Key? key, this.rouletteId}) : super(key: key);

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage>
    with SingleTickerProviderStateMixin //アニメーションが一つだけの場合
{

  var appLocalizations = AppLocalizations(); //多言語対応用
  var _languageCode = 'en'; //言語設定用
  late List<TextEditingController> itemNameController;//テキストコントローラー
  late List<TextEditingController> ratioController;//テキストコントローラー
  late TextEditingController titleController;//テキストコントローラー
  List<int> _usedColorsList = []; //使っているカラーを調べるためのリスト


  List<Map<String, dynamic>> _parts = [];
  bool _isLoading = true; //画面更新グルグルに使う判定値
  bool _isDisabled = false; //連打防止のための判定値
  late String rouletteTitle;  //ルーレットのタイトル
  final ScrollController _scrollController = ScrollController(); //スクロール用
  final _colorSelectList = ColorList().colorSelectList; //カラーリスト

  //言語設定に応じてmaxLengthの値を変える処理
  var titleMaxLength = 24;  //タイトルの最大文字数
  var itemNameMaxLength = 16; //アイテム名の最大文字数
  final focusNode = FocusNode();
  var paddingBottom = 60.0;

  var bottomSpace = 0.0;

  final _focusNode = FocusNode(); //フォーカス用



  @override
  void initState() {
    rouletteTitle = '';
    super.initState();
    _getLanguage();

    Future(() async {
      await _refreshParts();
      await _addUsedColors();
      await _getTitle();
      await _initTextController();
      await _setTextController();
      await _getLanguage();
      _getMaxLength();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; //画面サイズで指定用
    bottomSpace = 0; // この行がないとキーボードをしまう時にオーバーフローが発生

    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      // キーボードが出ている時
      paddingBottom = 0;
      bottomSpace = MediaQuery.of(context).viewInsets.bottom - 60;
    } else {
      // キーボードが出ていない時
      paddingBottom = 60.0;
      bottomSpace = 0.0;
    }

    // バナー広告の読み込み
    myBanner.load();

    final AdWidget adWidget = AdWidget(ad: myBanner);

    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );

    //帰ってきた時の処理

    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: focusNode.requestFocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Focus(
                    child: TextFormField(
                      controller: titleController,
                      cursorColor: Colors.black12,
                      maxLength: titleMaxLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        isDense: true,
                        //テキストフィールドの高さを低く設定できる
                        counterText: "",
                        labelText: appLocalizations.getTranslatedValue(
                            _languageCode, 'titleEdit'),
                        hintText: appLocalizations.getTranslatedValue(
                            _languageCode, 'titleHintText'),
                        hintStyle: const TextStyle(
                            fontSize: 12, color: Colors.black45),
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          //フォーカスした時の挙動
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.black45,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.black45,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        //フォーカスが外れた時の処理
                        _updateTitle(titleController.text);
                      }
                    },
                  ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _focusNode.unfocus(); // フォーカスを外す
                Navigator.pop(context, true);
              },
            ),
          ),
          resizeToAvoidBottomInset: false,//キーボードが出ても画面が上がらないようにする
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _focusNode.unfocus(); // フォーカスを外す
            },
                child: Center(
                    child: Column(
                      children: <Widget>[
                        Stack(alignment: AlignmentDirectional.center, children: [
                          SizedBox(
                            width: double.infinity,
                            height: screenSize.height * 0.25,
//                  height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PieChart(
                                PieChartData(
                                    sectionsSpace: 1,
                                    centerSpaceRadius: screenSize.height * 0.03,
//                        centerSpaceRadius: 20,
                                    centerSpaceColor: Colors.white,
                                    startDegreeOffset: 270,
                                    sections: [
                                      for (var i = 0; i < _parts.length; i++)
                                        PieChartSectionData(
                                          color: _colorSelectList[_parts[i]
                                              ['color']],
                                          value: _parts[i]['ratio'] / 10,
                                          radius: 60,
                                          title: _parts[i]['name'],
                                          titleStyle: const TextStyle(
                                            fontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ]),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0.1,
                            child: Text(
                              appLocalizations.getTranslatedValue(
                                  _languageCode, 'preview'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                              ),
                            ),
                          )
                        ]),
                        SingleChildScrollView(
                          child: SizedBox(
                            height: screenSize.height * 0.52 - bottomSpace,
//                  height: 300,
                            width: double.infinity,
                            child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _parts.length,
                                padding: EdgeInsets.only(bottom: paddingBottom),
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      height: 80,
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          // Icon(//ドラッグで移動用
                                          //   Icons.drag_indicator,
                                          //   size: 40,
                                          // ),
                                          SizedBox(
                                            height: 60,
                                            width: 40,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                pushWithReloadByReturn(
                                                    context, index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _colorSelectList[
                                                    _parts[index]['color']],
                                              ),
                                              child: null,
                                            ),
                                          ),
                                          Expanded(
                                            //項目名
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Focus(
                                                child: TextFormField(
//                                              textInputAction: TextInputAction.next,
                                                  controller:
                                                      itemNameController[index],
                                                  cursorColor: Colors.black12,
                                                  maxLength: itemNameMaxLength,
                                                  maxLengthEnforcement:
                                                      MaxLengthEnforcement
                                                          .enforced,
                                                  decoration: InputDecoration(
                                                    labelText: appLocalizations
                                                        .getTranslatedValue(
                                                            _languageCode,
                                                            'partsEdit'),
                                                    hintText: appLocalizations
                                                        .getTranslatedValue(
                                                            _languageCode,
                                                            'partsHintText'),
                                                    hintStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45),
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    counterText: "",
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      //フォーカスした時の挙動
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.black45,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.black45,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onFocusChange: (hasFocus) {
                                                  if (!hasFocus) {
                                                    //フォーカスが外れた時の処理
                                                    _updateItem(
                                                        _parts[index]['id'],
                                                        itemNameController[index]
                                                            .text,
                                                        int.parse(
                                                            ratioController[index]
                                                                .text));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            //比率
                                            width: 60,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Focus(
                                                child: TextFormField(
                                                  maxLength: 3,
                                                  maxLengthEnforcement:
                                                      MaxLengthEnforcement
                                                          .enforced,
                                                  onTap: () {
                                                    //選択時に全選択
                                                    ratioController[index]
                                                            .selection =
                                                        TextSelection(
                                                            baseOffset: 0,
                                                            extentOffset:
                                                                ratioController[
                                                                        index]
                                                                    .text
                                                                    .length);
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      ratioController[index],
                                                  cursorColor: Colors.black12,
                                                  decoration: InputDecoration(
                                                    labelText: appLocalizations
                                                        .getTranslatedValue(
                                                            _languageCode,
                                                            'ratioEdit'),
                                                    hintText: '$index ',
                                                    hintStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black45),
                                                    fillColor: Colors.white,
                                                    counterText: "",
                                                    filled: true,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      //フォーカスした時の挙動
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.black45,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.black45,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onFocusChange: (hasFocus) {
                                                  if (!hasFocus) {
                                                    //フォーカスが外れた時の処理
                                                    _updateItem(
                                                        _parts[index]['id'],
                                                        itemNameController[index]
                                                            .text,
                                                        int.parse(
                                                            ratioController[index]
                                                                .text));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8.0),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 40,
                                              ),
                                              onPressed: () {
                                                _parts.length <= 2
                                                    ? showDialog(
                                                        context: context,
                                                        barrierDismissible: false,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(appLocalizations
                                                                .getTranslatedValue(
                                                                    _languageCode,
                                                                    'attention')),
                                                            content: Text(
                                                              appLocalizations
                                                                  .getTranslatedValue(
                                                                      _languageCode,
                                                                      'partsAttention'),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      const Text(
                                                                    'OK',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ))
                                                            ],
                                                          );
                                                        },
                                                      ) //アラートを表示
                                                    : _deleteItem(
                                                        _parts[index]['id']);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Expanded(child: Container()),
                        adContainer,
                      ],
                    ),
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
                        const Duration(milliseconds: 200), //無効にする時間
                      );
                      _scrollController.animateTo(//スクロール
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linear,
                      );

                      await Future.delayed(
                        const Duration(milliseconds: 500), //無効にする時間
                      );


                      setState(() => _isDisabled = false); //ボタンを有効
                    },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  //広告用
  // バナー広告をインスタンス化
  final BannerAd myBanner = BannerAd(
    adUnitId: AdIdManagement.addEditBannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  _getLanguage() async {
    //言語設定を取得
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageCode = prefs.getString('languageCode') ?? 'ja';
    });
  }



  Future<void> _refreshParts() async {
    //データベースの一覧をパーツに登録。画面更新用
    final data = await PartsViewModel.getNotes(widget.rouletteId ?? 0);
    setState(() {
      _parts = data;
    });
  }

  Future<void> _getTitle() async {
    //タイトルを取得
    final data = await RouletteViewModel.getItem(widget.rouletteId ?? 0);
    setState(() {
      rouletteTitle = data[0]['name'];
//      _titleIsLoading = false;
    });
  }


  _addUsedColors() {
    //使っているカラーを調べるためのリストを作成
    _usedColorsList = [];
    for (var i = 0; i < _parts.length; i++) {
      _usedColorsList.add(_parts[i]['color']);
    }
  }

  _initTextController() {
    //テキストコントローラーの初期化
    itemNameController =
        List.generate(_parts.length, (index) => TextEditingController());

    ratioController =
        List.generate(_parts.length, (index) => TextEditingController());
    titleController = TextEditingController();
    titleController.text = rouletteTitle;
  }

  _setTextController() {
    //テキストコントローラーに値をセット
    for (var i = 0; i < _parts.length; i++) {
      itemNameController[i].text = _parts[i]['name'];
      ratioController[i].text = _parts[i]['ratio'].toString();
    }
  }

  _notUsedColorsCheck() {
    //使っていないカラーを調べる
    for (var i = 0; i < _colorSelectList.length; i++) {
      if (_usedColorsList.contains(i)) {
      } else {
        return i;
      }
    }
    //全部のカラーを使っていたらランダムでカラーを選択
    return math.Random().nextInt(_colorSelectList.length);
  }


  void _getMaxLength() {  //言語設定に応じてmaxLengthの値を変える処理
    if (_languageCode == 'ja') {
      titleMaxLength = 12;
      itemNameMaxLength = 8;
    } else {
      titleMaxLength = 24;
      itemNameMaxLength = 16;
    }
  }


  Future<void> _addItem() async { //アイテムを追加
    await PartsViewModel.createItem(
        widget.rouletteId ?? 0, '', _notUsedColorsCheck(), 1);
    await _refreshParts();
    await _addUsedColors();
    await _initTextController();//テキストコントローラーの初期化
    await _setTextController();//テキストコントローラーに値をセット
    _isLoading = false;
  }

  Future<void> _updateItem(int id, String name, int ratio) async {  //アイテムを更新
    await PartsViewModel.updateItem(id, name, ratio);
    await _refreshParts();
    _addUsedColors();
    _isLoading = false;
  }

  Future<void> _deleteItem(int id) async {  //アイテムを削除
    await PartsViewModel.deleteItem(id);
    await _refreshParts();
    await _addUsedColors();
    await _initTextController();
    await _setTextController();
    _isLoading = false;
  }

  Future<void> _updateTitle(rouletteTitle) async {  //タイトルを更新
    await RouletteViewModel.updateItem(widget.rouletteId ?? 0, rouletteTitle);
    _getTitle();
  }

  //帰ってきた時の処理

  void pushWithReloadByReturn(BuildContext context, index) async {  //アイテム追加画面に遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            ColorSelectPage(editColorId: index, rouletteId: widget.rouletteId),
      ),
    );
    if (result == null) {
      //帰ってきた時にresultがtrueになる
    } else {
      if (result) {
        setState(() {
          Future(() async {
            await _refreshParts();
            _addUsedColors();
          });
        });
      }
    }
  }



}
