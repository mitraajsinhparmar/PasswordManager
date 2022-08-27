import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:passwordmanager/DbHelper.dart';
import 'package:path_provider/path_provider.dart';



class apiDemo extends StatefulWidget {
  const apiDemo({Key? key}) : super(key: key);

  @override
  State<apiDemo> createState() => _apiDemoState();
}

class _apiDemoState extends State<apiDemo> {
   GoogleSignInAccount? user;
    var authHeaders;
   var authenticateClient;
   var driveApi;
   var resId;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Center(child: ElevatedButton(onPressed: () async{
                      signInGoogle(context);
                    setState((){});
                  }, child: Text("banna"),), ),
                  Center(child: ElevatedButton(onPressed: () async{
                        sendFile();
                    setState((){});
                  }, child: Text("banna"),), ),
                ],
              ),
            ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              logOut(context);
            },

          ),
          );
        }
      ),

    );
  }
  Future<void> logOut(BuildContext context)
  async {

    GoogleSignIn _googleSignin = GoogleSignIn();
    user = await _googleSignin.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("you have been logged out")));

    authHeaders = null;
    authenticateClient = null;
    driveApi = null;


    print("users.. $user");
  }
  Future<void> signInGoogle(BuildContext context)
  async {

    GoogleSignIn _googleSignin = GoogleSignIn.standard(scopes: [
       drive.DriveApi.driveAppdataScope, drive.DriveApi.driveFileScope,
      drive.DriveApi.driveScope,
    ]);

    print("google sign in   $_googleSignin");


    print("object created");
    if(user==null)
      {
        try
        {
          user = await _googleSignin.signIn();
          print("...user $user");
        }
        catch(error)
        {
          print("..error .... $error");
        }
         authHeaders = await user?.authHeaders;
        print("auth header $authHeaders ..... ${authHeaders.runtimeType}");
         authenticateClient = GoogleAuthClient(authHeaders!);
        print("auth client $authenticateClient ..... ${authenticateClient.runtimeType}");

        driveApi = drive.DriveApi(authenticateClient);
        print("driveApi  $driveApi ..... ${driveApi.runtimeType}");


      }
    else
      {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You have been already logged in as ${user?.email}")));
      }

  }

  Future<void> sendFile()
  async {

    Directory dir = await getApplicationDocumentsDirectory();
    File dbBackupFile = File(dir.path + "passwordManager.db");

  //   final Stream<Object> mediaStream =
  // Future.value([104, 105]).asStream().asBroadcastStream();
  // var media = new drive.Media(mediaStream, 2);


var result;
  var driveFile = new drive.File();
    driveFile.parents = ["appDataFolder"];
  driveFile.name = "banna.db";
  try
  {
     result = await driveApi.files.update(driveFile, "122ZrvgcqbfRgBFxOoGv3x_uWewO-opoU",uploadMedia: drive.Media(dbBackupFile.openRead(), dbBackupFile.lengthSync()));
      print("updated");
  } on Exception
    {
      result = await driveApi.files.create(driveFile,uploadMedia: drive.Media(dbBackupFile.openRead(), dbBackupFile.lengthSync()));
      resId = result.id;
    }

  print("Upload result: ${result.id}");
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