import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:volume_control/volume_control.dart';
import 'package:flutter/services.dart';
import 'DbHelper.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'dart:async';
import 'main.dart';

class archivePageCon extends StatelessWidget {
  const archivePageCon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: archivePage(),
    );
  }
}
//
class archivePage extends StatefulWidget {
  const archivePage({Key? key}) : super(key: key);

  @override
  State<archivePage> createState() => _archivePage();
}
//
class _archivePage extends State<archivePage> {
  late final Box box;
  var myLeading = null;
  TextEditingController searchText = new TextEditingController();
  Color myColor = Colors.teal;
  Widget myTitle = Text('Password Manager');
  Icon mySearchIcon = Icon(Icons.search);

  bool passwordState = true;

  int ges = 0;
  double currentVol = 0.86666;

  TextEditingController titletxt = new TextEditingController();
  TextEditingController userNametxt = new TextEditingController();
  TextEditingController passwordtxt = new TextEditingController();
  TextEditingController searchtxt = new TextEditingController();

  String title = '',
      userName = '',
      password = '',
      search = '';
  String sql = '';

  DbHelper db = DbHelper();
  var table;
  int length = 0;
  final myForm = GlobalKey <FormState>();

  int sortValue = 0;

  @override
  initState() {
    box = Hive.box('sortBox2');
    if (box.isNotEmpty) {
      sortValue = box.get('state');
    }

    VolumeControl.setVolume(currentVol);
    Future.delayed(Duration.zero, () async {
      currentVol = await PerfectVolumeControl.getVolume();
      //get current volume
      setState(() {
        //refresh UI
      });
    });

    titletxt.addListener(() {
      title = titletxt.text;
    });

    userNametxt.addListener(() {
      userName = userNametxt.text;
    });

    passwordtxt.addListener(() {
      password = passwordtxt.text;
    });
    searchtxt.addListener(() {
      search = searchtxt.text;
    });

    PerfectVolumeControl.stream.listen((volume) {
      PerfectVolumeControl.hideUI = false;
      if (volume != currentVol) {
        if (volume == 1.0) {
          setState(() {
            passwordState = false;
          });
        } else {
          setState(() {
            passwordState = true;
          });
        }
      }
    });

    //Database
    getData();
  }

  Future getSearch() async {
    table = await db.fetchRow(sql);
    setState(() {
      length = table.length;
    });
  }

  Future getData() async {
    if (sortValue == 0) {
      sql =
      ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=1 and isDeleted=0 order by id''';
    }
    else if (sortValue == 1) {
      sql =
      ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=1 and isDeleted=0 order by timeDate DESC''';
    }
    else if (sortValue == 2) {
      sql =
      ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=1 and isDeleted=0 order by Domain ''';
    }
    else if (sortValue == 3) {
      sql =
      ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=1 and isDeleted=0 order by userName''';
    }

    table = await db.fetchRow(sql);
    setState(() {
      length = table.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (myColor == Colors.white) {
          setState(() {
            searchtxt.text = '';
            getData();
            myLeading = null;
            myTitle = Text('Password Manager');
            mySearchIcon = Icon(Icons.search);
            myColor = Colors.teal;
          });
          return false;
        }
        else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => homePage()
              ),
              ModalRoute.withName("/Home")
          );
          return false;
        }
      },
      child: MaterialApp(
        title: 'Password Manager App',
        debugShowCheckedModeBanner: false,
        home: Builder(builder: (context) {
          return Scaffold(
            backgroundColor: Color(0xff333333),
            appBar: AppBar(
              backgroundColor: myColor,
              leading: myLeading,
              title: myTitle,
              actions: [

                IconButton(
                    onPressed: () {
                      setState(() {
                        myLeading = IconButton(
                          onPressed: () {
                            setState(() {
                              searchtxt.text = '';
                              getData();
                              myLeading = null;
                              myTitle = Text('Password Manager');
                              mySearchIcon = Icon(Icons.search);
                              myColor = Colors.teal;
                            });
                          },
                          icon: Icon(Icons.arrow_back),
                          color: Colors.grey,
                        );
                        myTitle = TextField(
                          autofocus: true,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                if (sortValue == 0) {
                                  sql =
                                  ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=1 and isDeleted=0 and (userName LIKE '%$value%' or  domain LIKE '%$value%') order by id''';
                                }
                                else if (sortValue == 1) {
                                  sql =
                                  ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=1 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by timeDate DESC ''';
                                }
                                else if (sortValue == 2) {
                                  sql =
                                  ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=1 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by domain ''';
                                }
                                else if (sortValue == 3) {
                                  sql =
                                  ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=1 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by userName  ''';
                                }
                                getSearch();
                              });
                            }
                            else {
                              getData();
                              setState(() {});
                            }
                          },
                          controller: searchtxt,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        );
                        myColor = Colors.white;
                        mySearchIcon = Icon(null);
                      });
                    },
                    icon: mySearchIcon),


                myColor == Colors.white
                    ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchtxt.text = '';
                        getData();
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: search.isEmpty == true ? Colors.white : Colors
                          .black,
                    ))
                    : IconButton(
                    onPressed: () {
                      displayBottomSheet(context);
                    },
                    icon: Icon(Icons.sort)),
              ],
            ),

            body: length != 0 ? ListView.builder(
                itemCount: length,
                itemBuilder: (BuildContext context, int index) {
                  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

                  return InkWell(
                    onLongPress: () {
                      Clipboard.setData(
                          ClipboardData(text: table[index]['password']));
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 0, left: 1, right: 1),
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                              EdgeInsets.only(top: 3, left: 3),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    table[index]['domain']
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yy')
                                        .add_jm()
                                        .format(dateFormat.parse(
                                        table[index]
                                        ["timeDate"]))
                                        .toString() +
                                        "  ",
                                    textScaleFactor: 0.85,
                                    style: TextStyle(
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      right: 7,
                                      top: 7,
                                      bottom: 7,
                                      left: 9),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User Name: ',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.w500, ),
                                      ),
                                      Text(table[index]['userName']),
                                      Visibility(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(top: 7),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'Password: ',
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w500,),
                                              ),
                                              Text(
                                                table[index]
                                                ['fakePass'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        visible: passwordState,
                                      ),
                                      Visibility(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(top: 7),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                'Password: ',
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w500,),
                                              ),
                                              Text(
                                                table[index]
                                                ['password'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        visible: !passwordState,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton(
                                        itemBuilder: (ctx) =>
                                        [

                                          PopupMenuItem(
                                            child: Text('Edit'),
                                            value: 2,
                                          ),
                                          PopupMenuItem(child: Text('Restore'),
                                            value: 0,),
                                          PopupMenuItem(
                                            child: Text('Delete'),
                                            value: 1,
                                          ),
                                        ],
                                        icon: Icon(Icons.more_vert_rounded),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 0:
                                              {
                                                var id = table[index]['id'];
                                                var sql =
                                                ''' update  passwordManager SET archive = 0 where id = '$id' ''';
                                                db.runQuery(sql);
                                                getData();
                                                setState(() {});
                                              }
                                              break;
                                            case 1:
                                              {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Delete password',
                                                              style: TextStyle(
                                                                  color: Colors.red),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Text(
                                                          'Do you want to delete this Password? ',
                                                          style: TextStyle(
                                                              color: Colors.black),
                                                        ),
                                                        actions: [
                                                          ButtonBar(
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  var id =
                                                                  table[index]['id'];

                                                                  String sql =
                                                                  ''' update  passwordManager SET isDeleted = 1 where id = '$id' ''';
                                                                  db.runQuery(sql);
                                                                  getData();
                                                                  setState(() {});
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Text('Yes'),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors.red,
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Text('No'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              }
                                              break;
                                            case 2:
                                              {
                                                showDialogBox(context, index);
                                              }
                                              break;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }) : Center(child: searchtxt.text != '' ? Text(
              'No Result Found', style: TextStyle(color: Colors.white),) : Text(
              'No Archived Entry', style: TextStyle(color: Colors.white),),),

          );
        }),
      ),
    );
  }

  void showDialogBox(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add New Password"),
            content: SingleChildScrollView(
              child: Form(
                key: myForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        else {
                          return 'Enter Domain';
                        }
                      },
                      controller: domainCon(index),
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: 'Domain',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        //errorText: 'error message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        else {
                          return 'Enter UserName';
                        }
                      },
                      controller: userNameCon(index),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                        label: Text('email/ID/mobile'),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        else {
                          return 'Enter Password';
                        }
                      },
                      controller: passwordCon(index),
                      decoration: InputDecoration(
                          label: Text('Enter Your Password'),
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          errorStyle: TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            save(context, index);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: myColor,
                          ),
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            passwordtxt.text = '';
                            userNametxt.text = '';
                            titletxt.text = '';

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: myColor,
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          );
        });
  }

  void displayBottomSheet(BuildContext context) {
    var temp = sortValue;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear),
                        color: Colors.black,
                      ),
                      Text(
                        'Sort Books By',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[10],
                    thickness: 1.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: RadioListTile(
                      activeColor: Colors.teal,
                      title: Text(
                        'Last Added',
                        style: TextStyle(
                          fontWeight:
                          sortValue == 0 ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      value: 0,
                      groupValue: sortValue,
                      onChanged: (value) {
                        setState(() {
                          sortValue = int.parse(value.toString());
                        });
                      },
                      selected: sortValue == 0 ? true : false,
                      selectedTileColor: Colors.teal[200],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: RadioListTile(
                      activeColor: Colors.teal,
                      title: Text(
                        'Last Updated',
                        style: TextStyle(
                            fontWeight: sortValue == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.black),
                      ),
                      value: 1,
                      groupValue: sortValue,
                      onChanged: (value) {
                        setState(() {
                          sortValue = int.parse(value.toString());
                        });
                      },
                      selected: sortValue == 1 ? true : false,
                      selectedTileColor: Colors.teal[200],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: RadioListTile(
                      activeColor: Colors.teal,
                      title: Text(
                        'Domain(A to Z)',
                        style: TextStyle(
                            fontWeight: sortValue == 2
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.black),
                      ),
                      value: 2,
                      groupValue: sortValue,
                      onChanged: (value) {
                        setState(() {
                          sortValue = int.parse(value.toString());
                        });
                      },
                      selected: sortValue == 2 ? true : false,
                      selectedTileColor: Colors.teal[200],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: RadioListTile(
                      activeColor: Colors.teal,
                      title: Text(
                        'User Name(A to Z)',
                        style: TextStyle(
                            fontWeight: sortValue == 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.black),
                      ),
                      value: 3,
                      groupValue: sortValue,
                      onChanged: (value) {
                        setState(() {
                          sortValue = int.parse(value.toString());
                        });
                      },
                      selected: sortValue == 3 ? true : false,
                      selectedTileColor: Colors.teal[200],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: ElevatedButton(
                      onPressed: temp == sortValue ? null : () {
                        getData();
                        setState(() {
                          box.put('state', sortValue);
                        });
                        Navigator.pop(context);
                      }, child: Text('Apply'),
                      style: ElevatedButton.styleFrom(primary: Colors.teal),
                    ),
                  ),
                ],
              ));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white);
  }

  TextEditingController domainCon(int index) {
    titletxt.text = table[index]['domain'];
    return titletxt;
  }

  TextEditingController userNameCon(int index) {
    userNametxt.text = table[index]['userName'];
    return userNametxt;
  }

  TextEditingController passwordCon(int index) {
    passwordtxt.text = table[index]['password'];
    return passwordtxt;
  }

  save(BuildContext context, int index) {
    if (myForm.currentState!.validate()) {
      myForm.currentState!.save();
      List spChar = ['@', '#', '\$', '*'];
      String t1 = '';
      try {
        int.parse(userName);
        t1 = password.substring(0, (((userName.length) / 2) - 2).round());
      } on FormatException {
        t1 = userName.substring(0, 1).toUpperCase() +
            userName.substring(1, ((userName.length) / 2).round());
      }

      String t2 = title.length.toString() +
          (title.length + 2).toString() +
          (title.length + 4).toString();

      String t4 = title.substring(0, ((title.length) / 2).ceil()).toUpperCase();
      String fakePass = t1 + t2 + spChar[(userName.length) % 4] + t4;
      String sql = '';

      String timeDate = DateTime.now().toString();


      var id = table[index]['id'];
      sql =
      ''' update  passwordManager set domain='$title',userName='$userName',password='$password',fakePass='$fakePass', timeDate='$timeDate' where id = '$id' ''';

      db.runQuery(sql);
      getData();
      setState(() {});
      titletxt.text = '';
      userNametxt.text = '';
      passwordtxt.text = '';
      Navigator.of(context).pop();
    }
  }
}

