import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'DbHelper.dart';

class DbHelper2 {

  static DbHelper2? _instance;
  static Database? db;
  DbHelper mainDB = DbHelper();

  DbHelper2._();

  factory DbHelper2()
  {
    if (_instance == null) {
      _instance = DbHelper2._();
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
    Directory appdir = await getTemporaryDirectory();


        String dbName = appdir.path + '/passwordManagerBackup.db';

        Database db = await openDatabase(dbName, version: 1);
        return db;



  }

  Future runQuery(String sql) async
  {
    Database db = await getdatabase;
    db.execute(sql);

  }

  Future getData() async
  {
    Database db = await getdatabase;
    List<Map<String, Object?>> result = await db.rawQuery(" SELECT * FROM passwordManager ");
    for(int i = 0; i< result.length; i++)
      {
       var mainData = await mainDB.fetchRow(''' select * from passwordManager where userName ='${result[i]['userName']}' and domain= '${result[i]['domain']}' and isDeleted = '${result[i]['isDeleted']}' and archive = '${result[i]['archive']}'  ''');
       if(mainData.length == 0)
         {
           mainDB.runQuery('''INSERT INTO passwordManager(domain,userName,password,fakePass,timeDate,isDeleted,archive) values ('${result[i]['domain']}','${result[i]['userName']}','${result[i]['password']}','${result[i]['fakePass']}','${result[i]['timeDate']}', '${result[i]['isDeleted']}',  '${result[i]['archive']}')  ''');
         }
        }

  }
  deleteDb()async{
    try{
      db = null;
      Directory appdir = await getTemporaryDirectory();
      await deleteDatabase(appdir.path + '/passwordManagerBackup.db');
      await deleteDatabase(appdir.path + '/passwordManagerBackup.db-shm');
      await deleteDatabase(appdir.path + '/passwordManagerBackup.db-wal');
    }
    catch (e)
    {

    }

  }

}








