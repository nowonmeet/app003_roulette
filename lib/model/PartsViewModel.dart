import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class PartsViewModel{

  static Future<void> createTables(sql.Database database) async{
    await database.execute("""CREATE TABLE items( 
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    roulette_id INTEGER NOT NULL,
    name TEXT,
    color INTEGER NOT NULL,
    ratio INTEGER
    )
     """);//テーブルの構造
  }

  static Future<sql.Database> db() async{//データベースを開く
    return sql.openDatabase(
      'parts.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(int rouletteId,String name, int color, int ratio) async{//データベースの作成
    final db = await PartsViewModel.db();
    final data = {'roulette_id':rouletteId, 'name': name, 'color': color,'ratio': ratio};
    final id = await db.insert(('items'), data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;

  }

  static Future<List<Map<String, dynamic>>> getNotes(int rouletteId) async{//データベースの取得
    final db = await PartsViewModel.db();
    return db.query('items',where: "roulette_id = $rouletteId", orderBy: "id");//itemsを読み取って。id順に

  }

  // static Future<List<Map<String, dynamic>>> getNotes(int rouletteId) async{//データベースの取得
  //   final db = await PartsViewModel.db();
  //   return db.query('items',where: "roulette_id = $rouletteId", orderBy: "id");//itemsを読み取って。id順に
  // }

  static Future<List<Map<String, dynamic>>> getColors() async{//データベースの取得
    final db = await PartsViewModel.db();
    return db.query('items', orderBy: "color");//itemsを読み取って。id順に
  }




  static Future<List<Map<String,dynamic>>> getItem(int id) async{//選択したidを取得
    final db = await PartsViewModel.db();
    return db.query('items', where: "id = ?",whereArgs: [id],limit: 1);
  }

  static Future<int> updateItem( //更新　name と　description を引数にしている。
      int id, String name ,int ratio) async {
//    int id, String name, int color) async {
    final db = await PartsViewModel.db();

    final data = {
      'name': name,
      'ratio' : ratio,
    };

    final result =
    await db.update('items',data,where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int> updateColor( //更新　name と　description を引数にしている。
      int id ,int color) async {
//    int id, String name, int color) async {
    final db = await PartsViewModel.db();

    final data = {
      'color': color,
    };

    final result =
    await db.update('items',data,where: "id = ?", whereArgs: [id]);
    return result;
  }


  static Future<void> deleteItem(int id) async {//アイテム削除
    final db = await PartsViewModel.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);

    }catch(err) {
      debugPrint("Something went wrong when deleting an item : $err");
    }
  }

  static Future<void> deleteRouletteItem(int rouletteId) async {//ルーレットのアイテムをまとめて削除
    final db = await PartsViewModel.db();
    try {
      await db.delete("items", where: "roulette_id = ?", whereArgs: [rouletteId]);

    }catch(err) {
      debugPrint("Something went wrong when deleting an item : $err");
    }
  }


}