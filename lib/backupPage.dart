import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'backupDB.dart';
import 'main.dart';

class backupData extends StatefulWidget {
  const backupData({Key? key}) : super(key: key);

  @override
  State<backupData> createState() => _backupDataState();
}

class _backupDataState extends State<backupData> {
  Color myColor = Colors.teal;
  Widget myTitle = Text('Password Manager');
  late final Box box;
  late BuildContext glob;

  //drive variable
  GoogleSignInAccount? user;
  GoogleSignIn _googleSignin = GoogleSignIn.standard(scopes: [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveScope,
  ]);
  var driveApi;
  var authHeaders;
  var authenticateClient;
  bool loginState = false;
  DbHelper2 db2 = new DbHelper2();

  @override
  initState() {
    boxInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    glob = context;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => homePage()),
            ModalRoute.withName("/Home"));
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xff333333),
        appBar: AppBar(
          backgroundColor: myColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => homePage()),
                  ModalRoute.withName("/Home"));
            },
          ),
          title: myTitle,
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Google drive Sync",
                  textScaleFactor: 1.2,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.info,
                      color: Colors.white,
                    )),
              ],
            ),
            loginState == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Account",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${user?.email}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              syncDialog(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text("Sync Data"),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text("Retrive Data"),
                            ),
                            onTap: () {
                              retriveDialog(context);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          child: InkWell(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Unlink Account",
                                ),
                              ),
                              onTap: () async {
                                unlinkAccount();
                              }),
                        ),
                      ),
                    ],
                  )
                : Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Card(
                      child: InkWell(
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Text(
                              "Tap here to link google drive account",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                        onTap: () async {
                          late BuildContext dialogCon;
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                dialogCon = context;
                                return Dialog(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.teal,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text("Connecting..."),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              useRootNavigator: true);
                          String msg = '';
                          try {
                            await linkToDrive(context);
                          } catch (e) {
                            msg = "Unable to link";
                            showSnack(msg: msg);
                          }
                          Navigator.of(dialogCon, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> linkToDrive(BuildContext context) async {
    if (loginState == false) {
      user = await _googleSignin.signIn();
      authHeaders = await user?.authHeaders;
      authenticateClient = GoogleAuthClient(authHeaders!);
      driveApi = drive.DriveApi(authenticateClient);

      setState(() {
        box.put("user", user.toString());
        loginState = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You have been already logged in as ${user?.email}")));
    }
  }

  syncDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sync Data : Google Drive"),
            content: Text(
                "Syncing data will upload your device database copy to google Drive. If file is found in Google Drive, it will be overwritten with your latest device Data"),
            actions: [
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showProgress(context);
                    },
                    child: Text(
                      'Okay Sync',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future unlinkAccount() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Unlink Account',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              'Please note that data in Google Drive will not be deleted. you can link account again and get data from Google Drive',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      user = await _googleSignin.signOut();

                      setState(
                        () {
                          driveApi = null;
                          authHeaders = null;
                          authenticateClient = null;
                          loginState = false;
                          box.clear();
                        },
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Okay',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  retriveDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Retrieve Data : Google Drive"),
            content: Text(
                "Retrieving data from Google Drive will append the cloud copy to your device copy. You will be able to access both device and Google drive passwords"),
            actions: [
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      retrieveProgress(context);
                    },
                    child: Text(
                      'Okay',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  retrieveProgress(BuildContext con) async {
    late BuildContext dialogCon;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogCon = context;
          return Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircularProgressIndicator(
                    color: Colors.teal,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Retrieving..."),
                ],
              ),
            ),
          );
        },
        useRootNavigator: true);
    String msg = '';
    try {
      msg = await retrieveData(context);
    } catch (e) {
      showSnack(msg: e.toString());
    }
    showSnack(msg: msg);

    Navigator.of(dialogCon, rootNavigator: true).pop();
  }

  Future<void> boxInit() async {
    box = Hive.box('userData');
    if (box.isNotEmpty) {
      setState(() {
        loginState = true;
      });
      if (user == null) {
        user = await _googleSignin.signIn();
        authHeaders = await user?.authHeaders;
        authenticateClient = GoogleAuthClient(authHeaders!);
        driveApi = drive.DriveApi(authenticateClient);
        setState(() {});
      }
    }
  }

  creatbackupFolder() async {
    var driveFile = new drive.File();
    driveFile.parents = ["appDataFolder"];
    driveFile.name = 'passwordManagerBackupFolder';
    driveFile.mimeType = 'application/vnd.google-apps.folder';
    return await driveApi.files.create(driveFile);
  }

  fileCount() async {
    var fileList = await driveApi.files.list(
      spaces: "appDataFolder",
      q: "name contains 'passwordManagerBackupFolder'",
    );
    if (fileList.files.length == 1) {
      await driveApi.files.delete(fileList.files[0].id);

      var folder = await creatbackupFolder();
      return folder.id;
    }
    var folder = await creatbackupFolder();
    return folder.id;
  }

  Future<String> syncData(BuildContext context) async {
    int status = await checkPermission();
    if (status != 1) {
      return "permission is necessary";
    }

    Directory dir = await getApplicationDocumentsDirectory();
    File dbBackupFiledb = await File(dir.path + "/passwordManager.db");
    File dbBackupFilewal = await File(dir.path + "/passwordManager.db-wal");
    File dbBackupFileshm = await File(dir.path + "/passwordManager.db-shm");

    try {
      String _fId = await fileCount();

      if (await dbBackupFilewal.exists()) {
        await driveApi.files.create(
            drive.File()
              ..parents = [_fId]
              ..name = 'passwordManagerBackup.db-wal',
            uploadMedia: drive.Media(
                dbBackupFilewal.openRead(), dbBackupFilewal.lengthSync()));
      }

      if (await dbBackupFileshm.exists()) {
        await driveApi.files.create(
            drive.File()
              ..parents = [_fId]
              ..name = 'passwordManagerBackup.db-shm',
            uploadMedia: drive.Media(
                dbBackupFileshm.openRead(), dbBackupFileshm.lengthSync()));
      }

      if (await dbBackupFiledb.exists()) {
        await driveApi.files.create(
            drive.File()
              ..parents = [_fId]
              ..name = 'passwordManagerBackup.db',
            uploadMedia: drive.Media(
                dbBackupFiledb.openRead(), dbBackupFiledb.lengthSync()));
      }
    } catch (e) {
      return e.toString();
    }
    return "Data synced successfully";
  }

  Future<String> retrieveData(BuildContext context) async {
    int status = await checkPermission();
    if (status != 1) {
      return "permission is necessary";
    }

    try {
      var folder = await driveApi.files.list(
        spaces: "appDataFolder",
        q: "name contains 'passwordManagerBackupFolder'",
      );

      if (folder.files.length == 1) {
        String _fId = folder.files[0].id;

        var fileList = await driveApi.files.list(
          spaces: "appDataFolder",
          q: "'$_fId' in parents",
        );
        Directory dir = await getTemporaryDirectory();

        for (int i = 0; i < fileList.files.length; i++) {
          List<int> dataStore = [];
          String name = fileList.files[i].name;
          File file = await File("${dir.path}/$name");

          var db = await driveApi.files.get(fileList.files[i].id,
              downloadOptions: drive.DownloadOptions.fullMedia);

          db.stream.listen((data) {
            dataStore.insertAll(dataStore.length, data);
          }, onDone: () async {
            await file.writeAsBytes(dataStore);
            if (i == fileList.files.length - 1) {
              await db2.getData();
              await db2.deleteDb();
            }
          }, onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.toString()),
            ));
          });

        }
      } else {
        return "oops! No data found on drive!";
      }
    } catch (e) {
      return e.toString();
    }
    return "Data retrieved successfully";
  }

  showProgress(BuildContext context) async {
    late BuildContext dialogCon;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogCon = context;
          return Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircularProgressIndicator(
                    color: Colors.teal,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Syncing..."),
                ],
              ),
            ),
          );
        },
        useRootNavigator: true);

    String msg = '';
    try {
      msg = await syncData(context);
    } catch (e) {
      showSnack(msg: e.toString());
    }
    showSnack(msg: msg);
    Navigator.of(dialogCon, rootNavigator: true).pop();
  }

  showSnack(
      {String msg = "Unable to open drive, please logout and login again!"}) {
    ScaffoldMessenger.of(glob).showSnackBar(SnackBar(
      backgroundColor: Colors.grey[300],
      content: Text(
        msg,
        style: TextStyle(color: Colors.black),
      ),
    ));
  }

  Future<int> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var val = await Permission.storage.request();
      if (!val.isGranted) {
        return 0;
      }
    }

    return 1;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
