class AppLocalizations {

static final Map<String, Map<String, String>> _localizedValues = {
  'en': {
    //起動アプリ一覧で表示するタイトル
    'title': 'Roulette',

    //初回起動時の説明
    'dice': 'Dice',

    //ルーレットページ
    'spin': 'Spin',
    'result': 'Result:',
    'menu': 'Menu',
    'privacy_policy': 'Privacy Policy',
    'inquiry': 'Inquiry by email',
    'languageSelect': 'Language Select',

    //コンタクトフォーム
    'emailSubject': 'Roulette Inquiry',
    'emailBody': 'Please enter the text from here.\n\n\n\n\nInformation required for app improvement: \n(Do not delete）\n',
    'emailError&Copy':'Mail app not found. Copied email address.',


    //ルーレットリスト
    'list': 'Roulette List',
    'check': 'Check',
    'deleteConfirmationMessage':'Do you want to delete the following roulette?\n\n',
    'attention':'Attention',
    'rouletteAttention':'Roulette is required at least one.',
    'newRoulette': 'New Roulette',


    //ルーレット編集
    'titleEdit': 'Roulette Title',
    'titleHintText': 'Please enter the title.',
    'partsEdit': 'Item Name',
    'partsHintText': 'Please enter the item name.',
    'partsAttention': 'Item name is required at least two.',
    'ratioEdit': 'Ratio',
    'preview': 'Preview',

    //色選択画面
    'colorTitle': 'Color Selection',

    //レビューをお願いするポップアップ
    'reviewTitle': 'Please review this app.',
    'reviewMessage': 'Please review this app.\n\nYour review will help us improve this app.',
    'reviewYes': 'Review',
    'reviewNo': 'No, thanks',

    //アプリを気に入ってもらえたか確認するポップアップを表示する。
    'likeAppTitle': 'Did you like this app?',
    'likeAppMessage': 'Did you like this app?\n\nPlease let us know what you liked about this app.',
    'likeAppYes': 'Yes',
    'likeAppNo': 'No, thanks',

    //アプリを気に入ってもらえなかったユーザーに対して、要望メールを送ってもらうポップアップを表示する。
    'requestTitle': 'Please send us your feedback.',
    'requestMessage': 'Please send us your feedback.\n\nYour feedback will help us improve this app.',
    'requestYes': 'Send',
    'requestNo': 'No, thanks',


  },
  'ja': {
    //起動アプリ一覧で表示するタイトル
    'title': 'ルーレット',

    //初回起動時の説明
    'dice': 'サイコロ',

    //ルーレットページ
    'spin': 'スピン',
    'result': '抽選結果:',
    'menu': 'メニュー',
    'privacy_policy': 'プライバシーポリシー',
    'inquiry': 'メールでお問い合わせ',
    'languageSelect': '言語選択',

    //コンタクトフォーム
    'emailSubject': 'ルーレットお問い合わせ',
    'emailBody': 'ここから本文を入力して下さい。\n\n\n\n\nアプリ改善に必要な情報:\n(削除しないでください）\n',
    'emailError&Copy':'メーラーアプリが見つかりませんでした。メールアドレスをコピーしました。',


    //ルーレットリスト
    'list': 'ルーレットリスト',
    'check': '確認',
    'deleteConfirmationMessage':'下記のルーレットを削除しますか？\n\n',
    'attention':'注意',
    'rouletteAttention':'ルーレットは一つ以上必要です。',
    'newRoulette': '新しいルーレット',

    //ルーレット編集
    'titleEdit': 'ルーレットタイトル',
    'titleHintText':'ルーレットタイトルを入力',
    'partsEdit': '項目名',
    'partsHintText':'ルーレットタイトルを入力',
    'partsAttention':'項目は2つ以上必要です。',
    'ratioEdit': '比率',
    'preview': 'プレビュー',

    //色選択画面
    'colorTitle': '色選択',

    //レビューをお願いするポップアップ
    'reviewTitle': 'レビューをお願いします',
    'reviewMessage': 'アプリをご活用いただきありがとうございます！\n\n少しでもアプリを気に入っていただけたら星５の評価をいただけると、開発者（わたし）が泣いて喜びます！\n\nレビューは最短10秒で終わります。\n\nより良い改善を目指しますので、よろしくお願いします。',
    'reviewYes': '星５で応援する',
    'reviewNo': '遠慮します',

    //アプリを気に入ってもらえたか確認するポップアップを表示する。
    'likeAppTitle': 'アプリをご利用いただき、ありがとうございます！',
    'likeAppMessage': 'このアプリは気に入ってもらえましたか？',
    'likeAppYes': '気に入った',
    'likeAppNo': '正直イマイチ',

    //アプリを気に入ってもらえなかったユーザーに対して、要望メールを送ってもらうポップアップを表示する。
    'requestTitle': 'ぜひご意見をお聞かせください',
    'requestMessage': 'アプリを気に入ってもらえなかった理由を教えていだたけませんか？\n\nあなたのお声を元に、より使いやすいアプリに改善させて下さい。',
    'requestYes': 'メールを送る',
    'requestNo': '遠慮します',

  },
};

String getTranslatedValue(String languageCode, String key) {

  return _localizedValues[languageCode]![key]??'';
}

}