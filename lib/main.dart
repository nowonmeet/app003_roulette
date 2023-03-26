import 'dart:io';
import 'dart:math';
import 'package:app003_roulette/pages/addEditPage.dart';
import 'package:app003_roulette/colorFile.dart';
import 'package:app003_roulette/pages/roulettePage.dart';
import 'package:app003_roulette/pages/settingPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'dart:math' as math;

import 'pages/listPage.dart';
import 'model/rouletteModel.dart';

void main()  {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());



}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ルーレット',
      theme: ThemeData(
        primarySwatch: OlignalColor.primaryColor,
//      primarySwatch: Colors.blue,
      ),
      home: const RoulettePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

//todo 見た目を作る
//todo メイン
//todo 一覧
//todo 作成・編集
//     ルーレットのプレビュー
//todo 色の選択
//todo 設定
