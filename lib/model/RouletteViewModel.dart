import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;


class RouletteViewModel{

  static Future<void> createTables(sql.Database database) async{
    await database.execute("""CREATE TABLE items( 
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDate TIMESTAMP,
    playedDate TIMESTAMP
    )
     """);//テーブルの構造
  }

  static Future<sql.Database> db() async{//データベースを開く
    return sql.openDatabase(
      'roulette.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await createTables(database);
      },
    );
  }

//  static Future<int> createItem(String name, DateTime createdDate) async{//データベースの作成
    static Future<int> createItem(String name) async{//データベースの作成
    final db = await RouletteViewModel.db();
//    final data = {'name': name, 'createdDate': createdDate};
    final data = {'name': name};
    final id = await db.insert(('items'), data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;

  }

  static Future<List<Map<String, dynamic>>> getNotes() async{//データベースの取得
    final db = await RouletteViewModel.db();
    return db.query('items', orderBy: "id");//itemsを読み取って。id順に
  }



  static Future<List<Map<String,dynamic>>> getItem(int id) async{//選択したidを取得
    final db = await RouletteViewModel.db();
    return db.query('items', where: "id = ?",whereArgs: [id],limit: 1);
  }

  // static Future<List<Map<String,dynamic>>> getItem() async{//選択したidを取得
  //   final db = await RouletteViewModel.db();
  //   return db.query('items', orderBy: "id",limit: 1);
  // }

  static Future<List<Map<String,dynamic>>> getLatestItem() async{//最新のidを取得
    final db = await RouletteViewModel.db();
    return db.query('items', orderBy:'createdDate DESC',limit: 1);
  }


  static Future<int> updateItem( //更新　name と　description を引数にしている。
      int id, String name,) async {
    final db = await RouletteViewModel.db();

    final data = {
      'id':id,
      'name': name,
      'updatedDate': DateTime.now().toString()
    };

    final result =
    await db.update('items',data,where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {//アイテム削除
    final db = await RouletteViewModel.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);

    }catch(err) {
      debugPrint("Something went wrong when deleting an item : $err");
    }
  }

}