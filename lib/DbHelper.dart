import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
class DbHelper {

  static DbHelper? _instance;
  static Database? db;
 var p;
  DbHelper._();

  factory DbHelper()
  {
    if (_instance == null) {
      _instance = DbHelper._();
      return _instance!;
    }
    return _instance!;
  }

  Future get getdatabase async
  {

    if (db == null) {
      db = await initializeDatabase();
      return db!;
    }

    return db!;
  }

  Future initializeDatabase() async
  {
    Directory appdir = await getApplicationDocumentsDirectory();
    String dbName = appdir.path + '/passwordManager.db';
    Database db = await openDatabase(dbName, version: 1, onCreate: creatTable);
    return db;
  }

  Future creatTable(Database db, int verion) async
  {
    await db.execute('''  CREATE TABLE IF NOT EXISTS passwordManager(id INTEGER PRIMARY KEY AUTOINCREMENT, domain TEXT NOT NULL, 
    userName TEXT, password TEXT NOT NULL, fakePass TEXT, archive INTEGER DEFAULT 0, isDeleted INTEGER DEFAULT 0, timeDate TEXT NOT NULL)  ''');

  }

  Future runQuery(String sql) async
  {
    Database db = await getdatabase;
    db.execute(sql);

  }

  Future<List<Map<String, Object?>>> fetchRow(String sql) async
  {
    Database db = await getdatabase;
    List<Map<String, Object?>> result = await db.rawQuery(sql);
    return result;
  }



}









