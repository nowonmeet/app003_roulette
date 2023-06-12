import 'package:app003_roulette/model/applocalizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:app_review/app_review.dart';

class ContactForm extends StatelessWidget {
  final String _languageCode;
  ContactForm({Key? key,required String languageCode})
      : _languageCode = languageCode, super(key: key);

  var appLocalizations = AppLocalizations();


  //メールでお問合せ用
  final String emailAddress = "now.on.meet.sup@gmail.com";
  // final String emailSubject = "ルーレットお問い合わせ";
  // final String emailBody =
  //     "ここから本文を入力して下さい。\n\n\n\n\nアプリ改善に必要な情報: \n(削除しないでください）\n";


  Future<String> getAppInformation() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceData;
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData = "version.sdkInt: ${androidInfo.version.sdkInt}\n"
          "board: ${androidInfo.board}\n"
          "brand: ${androidInfo.brand}\n"
          "device: ${androidInfo.device}\n"
          "display: ${androidInfo.display}\n"
          "manufacturer: ${androidInfo.manufacturer}\n"
          "model: ${androidInfo.model}\n"
          "product: ${androidInfo.product}\n"
          "type: ${androidInfo.type}\n"
          "version.release: ${androidInfo.version.release}\n"
          "version.securityPatch: ${androidInfo.version.securityPatch}\n";
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = "name: ${iosInfo.name}\n"
          "systemName: ${iosInfo.systemName}\n"
          "systemVersion: ${iosInfo.systemVersion}\n"
          "model: ${iosInfo.model}\n"
          "localizedModel: ${iosInfo.localizedModel}\n"
          "identifierForVendor: ${iosInfo.identifierForVendor}\n";
    }

    final appInformation =
        "app version: ${packageInfo.version}\n" + "device information: $deviceData";

    return appInformation;
  }

  Future<void> openMail() async{
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject':appLocalizations.getTranslatedValue(_languageCode,'emailSubject'),
        'body': appLocalizations.getTranslatedValue(_languageCode,'emailBody') + await getAppInformation(),
        //カーソルを本文の先頭に設定する
        'cursors': '0' // ここでカーソルを本文の先頭に設定します
      },
    );

    try {
      await launchUrlString(emailLaunchUri.toString());
    } on PlatformException {
      Clipboard.setData(ClipboardData(text: emailAddress));

    }


  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //メールで問い合わせ
      leading: const Icon(Icons.email),
      title:  Text(
        appLocalizations.getTranslatedValue(_languageCode,'inquiry'),
      ),
      onTap: () async {

        await openMail();
      },
    );
  }
}
