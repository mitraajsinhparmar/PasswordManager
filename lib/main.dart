import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:volume_control/volume_control.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'DbHelper.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'archive.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'backupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('sortBox');
  await Hive.openBox('sortBox2');
  await Hive.openBox('userData');
  await initialization(null);
  runApp(MaterialApp(
    home: homePage(),
    title: "Password Manager",
    debugShowCheckedModeBanner: false,
  ));
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 1));
}

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final myForm = GlobalKey<FormState>();
  late final Box box;

  var myLeading = null;
  Color myColor = Colors.teal;
  Widget myTitle = Text('Password Manager');
  Icon mySearchIcon = Icon(Icons.search);
  Widget myclear = IconButton(
    onPressed: () {},
    icon: Icon(
      Icons.clear,
      color: Colors.teal,
    ),
  );
  late Widget mySort;

  static bool passwordState = true;

  int ges = 0;
  double currentVol = 0.86666;

  TextEditingController titletxt = new TextEditingController();
  TextEditingController userNametxt = new TextEditingController();
  TextEditingController passwordtxt = new TextEditingController();
  TextEditingController searchtxt = new TextEditingController();

  String title = '', userName = '', password = '', search = '';
  DbHelper db = DbHelper();
  var table;
  int length = 0;
  String sql = '';
  int sortValue = 0;

  @override
  initState() {
    box = Hive.box('sortBox');
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

  Future getData() async {
    if (sortValue == 0) {
      sql =
          ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=0 and isDeleted=0 order by id''';
    } else if (sortValue == 1) {
      sql =
          ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=0 and isDeleted=0 order by timeDate DESC''';
    } else if (sortValue == 2) {
      sql =
          ''' Select id,domain,userName,password,fakePass,archive,timeDate from passwordManager where archive=0 and isDeleted=0 order by Domain ''';
    } else if (sortValue == 3) {
      sql =
          ''' Select id,domain,userName,password,fakePass,archive, timeDate from passwordManager where archive=0 and isDeleted=0 order by userName''';
    }
    table = await db.fetchRow(sql);
    setState(() {
      length = table.length;
    });
  }

  Future getSearch() async {
    table = await db.fetchRow(sql);
    setState(() {
      length = table.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager App',
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        return RefreshIndicator(
          onRefresh: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const archivePage()));
          },
          child: Scaffold(
            backgroundColor: Color(0xff333333),
            appBar: AppBar(
              backgroundColor: myColor,
              leading: myLeading,
              title: myTitle,
              actions: [
                WillPopScope(
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
                    } else {
                      return true;
                    }
                  },
                  child: IconButton(
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
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  if (sortValue == 0) {
                                    sql =
                                        ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=0 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by id''';
                                  } else if (sortValue == 1) {
                                    sql =
                                        ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=0 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%' ) order by timeDate DESC ''';
                                  } else if (sortValue == 2) {
                                    sql =
                                        ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=0 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by domain ''';
                                  } else if (sortValue == 3) {
                                    sql =
                                        ''' Select id,domain,userName,password,fakePass,archive from passwordManager where archive=0 and isDeleted=0 and (userName LIKE '%$value%' or domain LIKE '%$value%') order by userName  ''';
                                  }

                                  getSearch();
                                });
                              } else {
                                getData();
                                setState(() {});
                              }
                            },
                            autofocus: true,
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
                ),
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
                          color: search.isEmpty == true
                              ? Colors.white
                              : Colors.black,
                        ))
                    : PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(child: Text("⬆⬇ Sort"), value: 0),
                            PopupMenuItem(child: Text("Back Up"), value: 2),
                            PopupMenuItem(
                              child: Text("How to use?"),
                              value: 1,
                            ),
                          ];
                        },
                        icon: Icon(Icons.more_vert_rounded),
                        onSelected: (value) async {
                          switch (value) {
                            case 0:
                              {
                                displayBottomSheet(context);
                              }
                              break;
                            case 1:
                              {
                                String url =
                                    'https://www.youtube.com/watch?v=veo1bF2P6gs&feature=youtu.be';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrlString(url,
                                      mode: LaunchMode.externalApplication);
                                  closeInAppWebView();
                                } else {
                                  await launchUrlString(url,
                                      mode: LaunchMode.inAppWebView);
                                  closeInAppWebView();
                                }
                              }
                              break;
                            case 2:
                              {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => backupData()));
                              }
                          }
                        },
                      ),
              ],
            ),
            body: length != 0
                ? ListView.builder(
                    itemCount: length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                      return index == length
                          ? SizedBox(
                              height: 72,
                            )
                          : InkWell(
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(
                                    text: table[index]['password']));
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 0, left: 3, right: 3),
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
                                                  itemBuilder: (ctx) => [
                                                    PopupMenuItem(
                                                      child: Text('Edit'),
                                                      value: 2,
                                                    ),
                                                    PopupMenuItem(
                                                      child: Text('Archive '),
                                                      value: 0,
                                                    ),
                                                    PopupMenuItem(
                                                      child: Text('Delete'),
                                                      value: 1,
                                                    ),
                                                  ],
                                                  icon: Icon(
                                                      Icons.more_vert_rounded),
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 0:
                                                        {
                                                          var id = table[index]
                                                              ['id'];
                                                          var sql =
                                                              ''' update  passwordManager SET archive = 1 where id = '$id' ''';
                                                          db.runQuery(sql);
                                                          getData();
                                                          setState(() {});
                                                        }
                                                        break;
                                                      case 1:
                                                        {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Delete password',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  content: Text(
                                                                    'Do you want to delete this Password? ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  actions: [
                                                                    ButtonBar(
                                                                      children: [
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            var id =
                                                                                table[index]['id'];

                                                                            String
                                                                                sql =
                                                                                ''' update  passwordManager SET isDeleted = 1 where id = '$id' ''';
                                                                            db.runQuery(sql);
                                                                            getData();
                                                                            setState(() {});
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text('Yes'),
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            primary:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text('No'),
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
                                                          showDialogBox(
                                                              context, index);
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
                    })
                : ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height) * 0.8 / 2),
                        child: Center(
                          child: searchtxt.text != ''
                              ? Text(
                                  'No Result Found',
                                  style: TextStyle(color: Colors.white),
                                )
                              : Text(
                                  'No password entry',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: myFloatingButtonFunction(context),
          ),
        );
      }),
    );
  }

  dynamic myFloatingButtonFunction(BuildContext context) {
    if (myColor == Colors.white) {
      return null;
    } else {
      return FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
        onPressed: () {
          showDialogBox(context, null);
        },
      );
    }
  }

  void showDialogBox(BuildContext context, int? index) {
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
                        } else {
                          return 'Enter Domain';
                        }
                      },
                      controller: index == null ? titletxt : domainCon(index),
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
                        } else {
                          return 'Enter UserName';
                        }
                      },
                      controller:
                          index == null ? userNametxt : userNameCon(index),
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
                        } else {
                          return 'Enter Password';
                        }
                      },
                      controller:
                          index == null ? passwordtxt : passwordCon(index),
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
                              width: 2.0,
                            ),
                          ),
                          errorStyle: TextStyle(fontWeight: FontWeight.bold)),
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

  save(BuildContext context, int? index) {
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

      if (index == null) {
        sql =
            ''' INSERT INTO passwordManager(domain,userName,password,fakePass,timeDate) values ('$title','$userName','$password','$fakePass','$timeDate')  ''';
      } else if (index != null) {
        var id = table[index]['id'];
        sql =
            ''' update  passwordManager set domain='$title',userName='$userName',password='$password',fakePass='$fakePass', timeDate='$timeDate' where id = '$id' ''';
      }
      db.runQuery(sql);
      getData();
      setState(() {});
      titletxt.text = '';
      userNametxt.text = '';
      passwordtxt.text = '';
      Navigator.of(context).pop();
    }
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
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: temp == sortValue
                      ? null
                      : () {
                          getData();
                          setState(() {
                            box.put('state', sortValue);
                          });
                          Navigator.pop(context);
                        },
                  child: Text('Apply'),
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

  updateSortState(int state) {
    box.put('state', state);
  }

  @override
  void dispose() {
    Hive.close(); // to close one box =>  Hive.box('boxname').close();
    super.dispose();
  }
}
