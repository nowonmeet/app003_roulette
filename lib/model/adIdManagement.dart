import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdIdManagement{

//rouletteページの広告ID
  static String get rouletteBannerAdUnitId {
    bool isDebug = false;
    assert (isDebug = true);
    if (isDebug) {//デバッグ環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-2993197407852082/7126531618';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2993197407852082/1547815571';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  //リストページの広告id
  static String get listBannerAdUnitId {
    bool isDebug = false;
    assert (isDebug = true);
    if (isDebug) {//デバッグ環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {//本番環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-2993197407852082/7604875896';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2993197407852082/5059421847';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  //addEditページの広告id
  static String get addEditBannerAdUnitId {
    bool isDebug = false;
    assert (isDebug = true);
    if (isDebug) {//デバッグ環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {//本番環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-2993197407852082/6480578057';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2993197407852082/6859852001';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  //カラーセレクトページの広告id
  static String get colorSelectBannerAdUnitId {
    bool isDebug = false;
    assert (isDebug = true);
    if (isDebug) {//デバッグ環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {//本番環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-2993197407852082/7566429019';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2993197407852082/5942356157';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }


  //tipsページの広告ID
  static String get tipsInterAdUnitId {
    bool isDebug = false;
    assert (isDebug = true);
    if (isDebug) {//デバッグ環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {//本番環境
      if (Platform.isAndroid) {
        return 'ca-app-pub-2993197407852082/8344505598';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-2993197407852082/8846304130';
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }



}