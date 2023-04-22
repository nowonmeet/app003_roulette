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
    'titleEdit': 'Roulette Title (Max 24 chars)',
    'titleHintText': 'Please enter the title.',
    'partsEdit': 'Item Name (Max 16 chars)',
    'partsHintText': 'Please enter the item name.',
    'partsAttention': 'Item name is required at least two.',
    'ratioEdit': 'Ratio',
    'preview': 'Preview',

    //色選択画面
    'colorTitle': 'Color Selection',

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
    'titleEdit': 'ルーレットタイトル（最大12文字）',
    'titleHintText':'ルーレットタイトルを入力',
    'partsEdit': '項目名（最大8文字）',
    'partsHintText':'ルーレットタイトルを入力',
    'partsAttention':'項目は2つ以上必要です。',
    'ratioEdit': '比率',
    'preview': 'プレビュー',

    //色選択画面
    'colorTitle': '色選択',
  },
};

String getTranslatedValue(String languageCode, String key) {

  return _localizedValues[languageCode]![key]??'';
}

}