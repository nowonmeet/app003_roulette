import 'dart:math';

import 'package:app003_roulette/model/adIdManagement.dart';
import 'package:app003_roulette/model/colorList.dart';
import 'package:app003_roulette/pages/colorSelectPage.dart';
import 'package:app003_roulette/pages/language_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isEditing = false; //編集中かどうか
  late String _rouletteTitle;
  late bool _isLanguageSelected; //言語が選択されているかどうか
  late bool _isEmptyRoulette; //ルーレットが空かどうか
  List<Map<String, dynamic>> _parts = []; //項目のリスト
  List<int> _ratioList = []; //比率のリスト
  int _rouletteId = 0;
  final _colorSelectList = ColorList().colorSelectList; //色のリストを読み込む
  final bool _clockwise = true; //時計回りかどうか
  var random = math.Random(); //ランダムを生成
  var _resultNumber = 0; //結果選択用
  var _rouletteResult = ''; //結果表示用
  var _languageCode = 'en'; //言語設定用
  var appLocalizations = AppLocalizations();
  var _isAnimation = false; //アニメーション中かどうか
  var _iconContainerHeight = 160.0; //アニメーション中のウィジェットの幅
  var _arrowIconSizeHeight = 50.0; //アニメーション中の矢印の高さサイズ
  var _arrowIconSizeWidth = 30.0; //アニメーション中の矢印の幅サイズ
  var _rouletteShadow = 300.0; //ルーレットの影の大きさ
  var _editingSpaceHeigth = 0.0; //編集中のスペースの高さ

  @override
  void initState() {
    //画面構築時
    Future(() async {
      await _firstStartup(); //初回起動時の処理
      await _getRouletteId(); //ルーレットIDを取得
      await _getTitle(_rouletteId); //ルーレットタイトルを取得
      await _reloadRoulette(); //ルーレットを再読み込み
      await _getLanguage(); //言語設定を取得

      //アドエディットページ

      //     await _refreshJournals();
      await _addUsedColors();
//      await _getTitle();
      await _initTextController();
      await _setTextController();
      //     await _getLanguage();
      _getMaxLength();
      _isLoading = false;
    });
    super.initState();
    _rouletteResult = ''; //結果表示用
  }

  @override
  Widget build(BuildContext context) {
    //アドエディットページ
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



    //
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
      onWillPop: () async => false,
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
              : isEditing
                  ? Focus(
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
                    )
                  : Text(_rouletteTitle),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage('lib/assets/drawer.png'))),
                child: Text(
                  appLocalizations.getTranslatedValue(_languageCode, 'menu'),
                ),
              ),
              ListTile(
                title: Text(
                  appLocalizations.getTranslatedValue(
                      _languageCode, 'privacy_policy'),
                ),
                leading: const Icon(Icons.vpn_key),
                onTap: () {
                  _privacyPolicyURL();
                  Navigator.pop(context); //Drawerを閉じる
                },
              ),
              ContactForm(languageCode: _languageCode),
              ListTile(
                title: Text(
                  appLocalizations.getTranslatedValue(
                      _languageCode, 'languageSelect'),
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
        resizeToAvoidBottomInset: false,
        //キーボードが出ても画面が上がらないようにする

        body: _isAnimation
            ? _animationWidget()
            : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: Column(
                      children: <Widget>[
                        Visibility(
                          visible: !isEditing,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _rouletteResult = '';
                                      pushWithReloadByReturnListPage(context);
                                    },
                                    icon: const Icon(Icons.grid_view),
                                    iconSize: 48,
                                  ),
                                  // IconButton( //編集ページへ遷移するボタン
                                  //   onPressed: () {
                                  //     _rouletteResult = '';
                                  //     pushWithReloadByReturnAddEditPage(
                                  //         context);
                                  //   },
                                  //   icon: const Icon(Icons.edit),
                                  //   iconSize: 48,
                                  // ),
                                  Expanded(child: Container()),
                                  IconButton(
                                    onPressed: () {
                                      _rouletteResult = '';
                                      editMode();
                                    },
                                    icon: const Icon(Icons.edit),
                                    iconSize: 48,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 12.0),
                                      child: Text(
                                        appLocalizations.getTranslatedValue(
                                            _languageCode, 'result'),
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
                            ],
                          ),
                        ),
                        Stack(alignment: Alignment.topCenter, children: [
                          //ルーレットの表示
                          Padding(
                            padding: isEditing
                                ? const EdgeInsets.only(top: 10.0)
                                : const EdgeInsets.only(top: 52.0),
                            child: SizedBox(
                              //横幅は画面の8割
                              width: isEditing
                                  ? MediaQuery.of(context).size.width * 0.5
                                  : MediaQuery.of(context).size.width * 0.8,
                              height: isEditing
                                  ? MediaQuery.of(context).size.width * 0.5
                                  : MediaQuery.of(context).size.width * 0.8,

                              child: _isLoading
                                  ? Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.red,
                                    )
                                  : Roulette(
                                      controller: _controller,
                                      style: isEditing
                                          ? const RouletteStyle(
                                              dividerThickness: 1, //区切り線の幅
                                              centerStickSizePercent:
                                                  0.3, //真ん中の円の割合
                                              centerStickerColor:
                                                  Colors.white, //真ん中の円の色
                                            )
                                          : const RouletteStyle(
                                              dividerThickness: 2, //区切り線の幅
                                              centerStickSizePercent:
                                                  0.3, //真ん中の円の割合
                                              centerStickerColor:
                                                  Colors.white, //真ん中の円の色
                                            ),
                                    ),
                            ),
                          ),
                          Visibility(
                            visible: !isEditing,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SizedBox(
                                width: 30,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.grey, width: 1),
                                    elevation: 10,
                                    shape: const BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight:
                                              Radius.circular(double.infinity),
                                          bottomLeft:
                                              Radius.circular(double.infinity)),
                                    ),
                                  ),
                                  child: const Text(''),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(1, -1),
                            child: Visibility(
                              visible: isEditing,
                              child: IconButton(
                                onPressed: () {
                                  _rouletteResult = '';
                                  editMode();
                                },
                                icon: const Icon(Icons.check_box_rounded),
                                iconSize: 48,
                              ),
                            ),
                          ),
                        ]),
                        // Text(_parts.toString()),
                        // Text(_ratioList.toString()),

                        Visibility(
                          //編集モード
                          visible: isEditing,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _focusNode.unfocus(); // フォーカスを外す
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SingleChildScrollView(
                                //アドエディットページ
                                child: SizedBox(
                                  height: screenSize.height * 0.5 - bottomSpace,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: _parts.length,
                                      padding: EdgeInsets.only(
                                          bottom: paddingBottom),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
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
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          _colorSelectList[
                                                              _parts[index]
                                                                  ['color']],
                                                    ),
                                                    child: null,
                                                  ),
                                                ),
                                                Expanded(
                                                  //項目名
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Focus(
                                                      child: TextFormField(
//                                              textInputAction: TextInputAction.next,
                                                        controller:
                                                            itemNameController[
                                                                index],
                                                        cursorColor:
                                                            Colors.black12,
                                                        maxLength:
                                                            itemNameMaxLength,
                                                        maxLengthEnforcement:
                                                            MaxLengthEnforcement
                                                                .enforced,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: appLocalizations
                                                              .getTranslatedValue(
                                                                  _languageCode,
                                                                  'partsEdit'),
                                                          hintText: appLocalizations
                                                              .getTranslatedValue(
                                                                  _languageCode,
                                                                  'partsHintText'),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black45),
                                                          fillColor:
                                                              Colors.white,
                                                          filled: true,
                                                          counterText: "",
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            //フォーカスした時の挙動
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors
                                                                  .black45,
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors
                                                                  .black45,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      onFocusChange:
                                                          (hasFocus) {
                                                        if (!hasFocus) {
                                                          //フォーカスが外れた時の処理
                                                          _updateItem(
                                                              _parts[index]
                                                                  ['id'],
                                                              itemNameController[
                                                                      index]
                                                                  .text,
                                                              int.parse(
                                                                  ratioController[
                                                                          index]
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
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            ratioController[
                                                                index],
                                                        cursorColor:
                                                            Colors.black12,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: appLocalizations
                                                              .getTranslatedValue(
                                                                  _languageCode,
                                                                  'ratioEdit'),
                                                          hintText: '$index ',
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black45),
                                                          fillColor:
                                                              Colors.white,
                                                          counterText: "",
                                                          filled: true,
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            //フォーカスした時の挙動
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors
                                                                  .black45,
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: Colors
                                                                  .black45,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      onFocusChange:
                                                          (hasFocus) {
                                                        if (!hasFocus) {
                                                          //フォーカスが外れた時の処理
                                                          _updateItem(
                                                              _parts[index]
                                                                  ['id'],
                                                              itemNameController[
                                                                      index]
                                                                  .text,
                                                              int.parse(
                                                                  ratioController[
                                                                          index]
                                                                      .text));
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 40,
                                                    ),
                                                    onPressed: () {
                                                      _parts.length <= 2
                                                          ? showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(appLocalizations
                                                                      .getTranslatedValue(
                                                                          _languageCode,
                                                                          'attention')),
                                                                  content: Text(
                                                                    appLocalizations.getTranslatedValue(
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
                                                                          style:
                                                                              TextStyle(color: Colors.black),
                                                                        ))
                                                                  ],
                                                                );
                                                              },
                                                            ) //アラートを表示
                                                          : _deleteItem(
                                                              _parts[index]
                                                                  ['id']);
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
                            ),
                          ),
                        ),
                        Expanded(child: Container()),

                        adContainer,
                      ],
                    ),
                  ),
        floatingActionButton: _isAnimation
            ? null
            : isEditing
                ? Container(
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
                              _scrollController.animateTo(
                                //スクロール
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
                  )
                : Container(
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
                          offset:
                              Random().nextDouble(), //項目内のずれ。1以上にすると別の項目に止まる
                        );

                        _resultDisplay();
                      },
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ),
      ),
    );
  }

  Widget _animationWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            height: _iconContainerHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.grid_view),
                        iconSize: 48,
                        color: Colors.grey[200],
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.edit),
                      //   iconSize: 48,
                      //   color: Colors.grey[200],
                      // ),
                      Expanded(child: Container()),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        iconSize: 48,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, right: 12.0),
                          child: Text(
                            appLocalizations.getTranslatedValue(
                                _languageCode, 'result'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFEEEEEE), //Colors.grey[200],と同じ
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
                ],
              ),
            ),
          ),
          Stack(alignment: Alignment.topCenter, children: [
            //ルーレットの表示
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,

                  //横幅は画面の8割
                  width: _rouletteShadow,
                  height: _rouletteShadow,
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.8 / 2),
                        color: Colors.grey[200],
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: AnimatedContainer(
                //ルーレットの矢印
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,

                width: _arrowIconSizeWidth,
                height: _arrowIconSizeHeight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
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

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              height: _editingSpaceHeigth,
              width: double.infinity,
              color: Colors.grey[200],
            ),
          ),
        ],
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

  Future<void> editMode() async {
    setState(() {
      isEditing = !isEditing;
      _isAnimation = true;
    });

    await Future.delayed(Duration(milliseconds: 30));
    setState(() {
      if (isEditing) {
        // 編集モードにする
        _iconContainerHeight = 0.0;
        _arrowIconSizeHeight = 0.0;
        _arrowIconSizeWidth = 0.0;
        _rouletteShadow = MediaQuery.of(context).size.width * 0.5;
        _editingSpaceHeigth = MediaQuery.of(context).size.height * 0.5;
      } else {
        _iconContainerHeight = 160.0;
        _arrowIconSizeHeight = 50.0;
        _arrowIconSizeWidth = 30.0;
        _rouletteShadow = MediaQuery.of(context).size.width * 0.8;
        _editingSpaceHeigth = 0.0;
      }
    });

    _reloadRoulette();
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isAnimation = false;
    });
  }

  _getRouletteId() async {
    //保存しているルーレットIDを取得
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

  _getLanguage() async {
    //言語設定を取得
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
              textStyle: isEditing
                  ? const TextStyle(
                      fontSize: 10,
                      shadows: <Shadow>[
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0.7, 0.7),
                          blurRadius: 3.0,
                        ),
                      ],
                    )
                  : const TextStyle(
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
    setState(() {
      _isLoading = true;
    });
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
    if (_isLanguageSelected) {
      //言語が選択されている場合のみ実行
      //_addItemFirstStartup()が実行されているかどうかを取得する。
      await _getIsEmptyRoulette();
      //ルーレット作成ずみかどうか確認する
      if (_isEmptyRoulette) {
        //ルーレット作成していない時のみ実行
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


  Future<void> _getIsEmptyRoulette() async {
    //ルーレットが空かどうか判別する。
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEmptyRoulette = prefs.getBool('isEmptyRoulette') ?? true;
    });
  }

  Future<void> _addItemFirstStartup() async {
    //初回起動のみ自動でルーレットを作成する
    await RouletteViewModel.createItem(
        appLocalizations.getTranslatedValue(widget.languageCode, 'dice'));
    await PartsViewModel.createItem(1, '１', 0, 1);
    await PartsViewModel.createItem(1, '２', 1, 1);
    await PartsViewModel.createItem(1, '３', 2, 1);
    await PartsViewModel.createItem(1, '４', 3, 1);
    await PartsViewModel.createItem(1, '５', 4, 1);
    await PartsViewModel.createItem(1, '６', 5, 1);
    _setIsEmptyRoulette();
  }

  // Shared PreferenceにIDを書き込む
  void _setIsEmptyRoulette() async {
    //ルーレット作成したらfalseにする
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEmptyRoulette', false);
  }

  void _resultDisplay() {
    //結果表示
    setState(() {
      _rouletteResult = _parts[_resultNumber]['name'].toString();
    });
  }

  void _displayReset() {
    //結果表示をリセット
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

  _privacyPolicyURL() async {
    //プライバシーポリシーに遷移

    String _privacyPolicyURLString = 'https://fir-memo-90c4e.web.app/';
    //言語に応じてURLを変更する。
    if (_languageCode == 'ja') {
      _privacyPolicyURLString = 'https://fir-memo-90c4e.web.app/';
    } else {
      _privacyPolicyURLString =
          'https://service-agreement-now-on-meet.web.app/';
    }

    //プライバシーポリシーに遷移
    if (await canLaunchUrlString(_privacyPolicyURLString)) {
      //URLを開けるかどうかチェック
      await launchUrlString(_privacyPolicyURLString);
    } else {
      throw 'Could not Launch $_privacyPolicyURLString';
    }
  }

  // void pushWithReloadByReturnAddEditPage(BuildContext context) async {
  //   //追加・編集画面に遷移する
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute<bool>(
  //       builder: (BuildContext context) => AddEditPage(rouletteId: _rouletteId),
  //     ),
  //   );
  //   if (result == null) {
  //     //帰ってきた時にresultがtrueになる
  //   } else {
  //     if (result) {
  //       setState(() {
  //         _getTitle(_rouletteId);
  //         _reloadRoulette();
  //       });
  //     }
  //   }
  // }

  void pushWithReloadByReturnListPage(BuildContext context) async {
    //リスト画面に遷移する
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
      _setRouletteId();  //ルーレットIDをSharedPreferenceに保存
      await _getTitle(_rouletteId); //ルーレットのタイトルを取得
      await _reloadRoulette();  //ルーレットを再読み込み
      await _initTextController();  //テキストコントローラーを初期化
      await _setTextController(); //テキストコントローラーに値を入れる
    setState(() {

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //アドエディットページ
  var bottomSpace = 0.0;
  final ScrollController _scrollController = ScrollController(); //スクロール用
  var paddingBottom = 60.0;
  late List<TextEditingController> itemNameController; //テキストコントローラー
  late List<TextEditingController> ratioController; //テキストコントローラー
  late TextEditingController titleController; //テキストコントローラー
  List<int> _usedColorsList = []; //使っているカラーを調べるためのリスト
  late String rouletteTitle; //ルーレットのタイトル
  final _focusNode = FocusNode(); //フォーカス用
  bool _isDisabled = false; //連打防止のための判定値

  //言語設定に応じてmaxLengthの値を変える処理
  var titleMaxLength = 24; //タイトルの最大文字数
  var itemNameMaxLength = 16; //アイテム名の最大文字数
  final focusNode = FocusNode();

  //帰ってきた時の処理

  void pushWithReloadByReturn(BuildContext context, index) async {
    //アイテム追加画面に遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            ColorSelectPage(editColorId: index, rouletteId: _rouletteId),
      ),
    );
    if (result == null) {
      //帰ってきた時にresultがtrueになる
    } else {
      if (result) {
        setState(() {
          Future(() async {
            await _reloadRoulette();
            _addUsedColors();
          });
        });
      }
    }
  }

  Future<void> _updateTitle(rouletteTitle) async {
    //タイトルを更新
    await RouletteViewModel.updateItem(_rouletteId, rouletteTitle);
    _getTitle(_rouletteId);
  }

  _addUsedColors() {
    //使っているカラーを調べるためのリストを作成
    _usedColorsList = [];
    for (var i = 0; i < _parts.length; i++) {
      _usedColorsList.add(_parts[i]['color']);
    }
  }

  void _getMaxLength() {
    //言語設定に応じてmaxLengthの値を変える処理
    if (_languageCode == 'ja') {
      titleMaxLength = 12;
      itemNameMaxLength = 8;
    } else {
      titleMaxLength = 24;
      itemNameMaxLength = 16;
    }
  }

  Future<void> _updateItem(int id, String name, int ratio) async {
    //アイテムを更新
    await PartsViewModel.updateItem(id, name, ratio);

    setState(() {
      _reloadRoulette();
    });
    _addUsedColors();
    _isLoading = false;
  }

  Future<void> _deleteItem(int id) async {
    //アイテムを削除
    await PartsViewModel.deleteItem(id);
    await _reloadRoulette();
    await _addUsedColors();
    await _initTextController();
    await _setTextController();
    _isLoading = false;
  }

  _initTextController() {
    //テキストコントローラーの初期化
    itemNameController =
        List.generate(_parts.length, (index) => TextEditingController());

    ratioController =
        List.generate(_parts.length, (index) => TextEditingController());
    titleController = TextEditingController();
    titleController.text = _rouletteTitle;
  }

  _setTextController() {
    //テキストコントローラーに値をセット
    for (var i = 0; i < _parts.length; i++) {
      itemNameController[i].text = _parts[i]['name'];
      ratioController[i].text = _parts[i]['ratio'].toString();
    }
  }

  Future<void> _addItem() async {
    //アイテムを追加
    await PartsViewModel.createItem(
        _rouletteId, '', _notUsedColorsCheck(), 1);
    await _reloadRoulette();
    await _addUsedColors();
    await _initTextController(); //テキストコントローラーの初期化
    await _setTextController(); //テキストコントローラーに値をセット
    _isLoading = false;
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
}
