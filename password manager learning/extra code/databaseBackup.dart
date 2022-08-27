import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class dbHelper
{
  static dbHelper? _instance;
  static Database? db;

  dbHelper._();

  factory dbHelper()
  {
    if(_instance == null)
      {
        _instance = dbHelper._();
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
    Directory path = await getExternalStorageDirectory();

    String dbName = path.path + "/banna/example.db";

    Database db = await openDatabase(dbName, version: 1);
    return db;
  }

  Future createTable(String sql)
  async {
    Database db = await getdatabase;

    await db.execute(sql);
  }
  
  Future setData(String sql)
  async {
   Database db = await getdatabase;
    db.execute(sql);
  }
  
  Future<List<Map<String, Object?>>> getData(String sql)
  async{
   Database db = await getdatabase;
    List<Map<String,dynamic>> data = await db.rawQuery(sql);
    return data;
  }



  backupDb()
  async {
    var status = await Permission.manageExternalStorage.status;
    if(!status.isGranted)
      {
        await Permission.manageExternalStorage.request();
      }
    var status2 = await Permission.storage.status;
    if(!status2.isGranted)
      {
        await Permission.storage.request();
      }

    try{
      var path = await getExternalStorageDirectory();
      print("getPath .... $path");
      File dbBackupFile = File(path.path + "/banna/example.db");
      File dbBackupFilewal = File(path.path + "/banna/example.db-wal");
      File dbBackupFileshm = File(path.path + "/banna/example.db-shm");
      Directory? storeFolder = Directory(path.path+"/banna1");
      await storeFolder.create();
      await dbBackupFile.copy(path.path + "/banna1/example.db");
      await dbBackupFilewal.copy(path.path + "/banna1/example.db-wal");
      await dbBackupFileshm.copy(path.path + "/banna1/example.db-shm");
    }
    catch(e)
    {
      print("error .... ${e.toString()}");
    }
  }
  restoreDb()
  async {
    var status = await Permission.manageExternalStorage.status;
    if(!status.isGranted)
    {
      await Permission.manageExternalStorage.request();
    }
    var status2 = await Permission.storage.status;
    if(!status2.isGranted)
    {
      await Permission.storage.request();
    }

    try{

      File restoredDb = File("/storage/emulated/0/PasswordManager/example.db");
      File restoredDbwal = File("/storage/emulated/0/PasswordManager/example.db-wal");
      File restoredDbshm = File("/storage/emulated/0/PasswordManager/example.db-shm");
      var path = await getExternalStorageDirectory();
      await restoredDb.copy(path.path + "/banna/example.db");
      await restoredDbwal.copy(path.path + "/banna/example.db-wal");
      await restoredDbshm.copy(path.path + "/banna/example.db-shm");

    }
    catch(e)
    {
      print("error .... ${e.toString()}");
    }
  }

  deleteDb()async{
   try{

     db = null;
    var path = await getExternalStorageDirectory();
    deleteDatabase( path.path+"/banna/example.db");
    deleteDatabase( path.path+"/banna/example.db-shm");
    deleteDatabase( path.path+"/banna/example.db-wal");
   }
   catch(e)
    {
      print("..... ${e.toString()}");
    }
  }

  insertDb() async {

    Database db = await getdatabase;
    db.execute(''' INSERT INTO passwordManager(domain,userName,password,fakePass,timeDate) values ('banna','mitrajsinh','king','banna','bapu') ''');

  }



}
class DbHelper2 {

  static DbHelper2? _instance;
  static Database? db;

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
    Directory appdir = await getExternalStorageDirectory();
    String dbName = appdir.path + "/banna1/example.db";
    Database db = await openDatabase(dbName, version: 1, onCreate: creatTable);

    return db;
  }

  Future creatTable(Database db, int verion) async
  {
    await db.execute('''  CREATE TABLE IF NOT EXISTS passwordManager(id INTEGER PRIMARY KEY AUTOINCREMENT, domain TEXT NOT NULL, 
    userName TEXT, password TEXT NOT NULL, fakePass TEXT, archive INTEGER DEFAULT 0, isDeleted INTEGER DEFAULT 0, timeDate TEXT NOT NULL)  ''');
    print("created new");
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

  deleteDb()async{
    try{

      db = null;
      Directory dir = await getExternalStorageDirectory();
      deleteDatabase( dir.path+"/passwordManager.db");
      print("deleted");
    }
    catch(e)
    {
      print("..... ${e.toString()}");
    }
  }




}


class mydb extends StatefulWidget {
  const mydb({Key? key}) : super(key: key);

  @override
  State<mydb> createState() => _mydbState();
}

class _mydbState extends State<mydb> {

  dbHelper db = dbHelper();
  var table = [];
  @override
  initState()
  {
    super.initState();


    //db.getDbPath();
    //db.backupDb();

  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            child: Column(
              children: [
                  Center(
                    child: ElevatedButton(onPressed: () async {
                      await db.deleteDb();
                      setState((){});
                    },child: Text("delete", textDirection: TextDirection.ltr,),),
                  ),
                  Center(
                    child: ElevatedButton(onPressed: () async {
                      await db.restoreDb();
                      DbHelper2 db2 = DbHelper2();
                      table = await db2.fetchRow(''' select * from passwordManager ''');
                      print(table);

                      print("restore");
                    },child: Text("restore", textDirection: TextDirection.ltr,),),
                  ),
                  Center(
                    child: ElevatedButton(onPressed: (){
                      db.backupDb();
                      print("backed up");
                    },child: Text("backup", textDirection: TextDirection.ltr,),),
                  ),
                Center(
                  child: ElevatedButton(onPressed: () async {


                      table = await db.getData(''' select * from passwordManager ''');
                      print(table);


                  },child: Text("display", textDirection: TextDirection.ltr,),),
                ),
                Center(
                  child: ElevatedButton(onPressed: () async {
                   await  db.createTable('''  CREATE TABLE IF NOT EXISTS passwordManager(id INTEGER PRIMARY KEY AUTOINCREMENT, domain TEXT NOT NULL, 
    userName TEXT, password TEXT NOT NULL, fakePass TEXT, archive INTEGER DEFAULT 0, isDeleted INTEGER DEFAULT 0, timeDate TEXT NOT NULL)  ''');

                   print("created");
                  },child: Text("create", textDirection: TextDirection.ltr,),),
                ),

                Center(
                  child: ButtonBar(
                   children: [
                     IconButton(onPressed: (){
                            db.insertDb();
                     }, icon: Icon(Icons.add), color: Colors.black,),
                     IconButton(onPressed: (){}, icon: Icon(Icons.remove), color: Colors.black,),
                   ],
                  ),
                ),
                  ListView.builder(itemBuilder: (BuildContext context, int index){
                    return Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("Domain :"),
                              Text(table[index]['domain'].toString()),
                            ],
                          ),
                          Row(
                            children: [
                              Text("user Name :"),
                              Text(table[index]['userName'].toString()),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Password  :"),
                             Text(table[index]['password'].toString()),
                            ],
                          ),
                        ],
                      ),
                    );
                  }, itemCount: table.length,
                  shrinkWrap: true,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

