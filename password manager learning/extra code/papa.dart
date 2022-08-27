import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class papa extends StatefulWidget {
  const papa({Key? key}) : super(key: key);

  @override
  State<papa> createState() => _papaState();
}

class _papaState extends State<papa> {
  late InAppWebViewController webView;


  @override
  Widget build(BuildContext context) {
    print("baanna");
    return MaterialApp(
      home: Scaffold(
        body:             InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse("https://www.truecaller.com/search/in/8780971422"),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webView = controller;
            },
            onReceivedServerTrustAuthRequest: (InAppWebViewController controller, URLAuthenticationChallenge challenge) async { return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED); },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: '''  ''');
            }

        ),

      ),
    );
  }

  List<int> numberList = [
    9426565019,7623889001,9725771135,9408211412,8469690266,9978407742,9978407742,9879275521,9879055251,9879055251,9978723201,9978723201,9023090859,9723977510,    9426565019,7623889001,9725771135,9408211412,8469690266,9978407742,9978407742,9879275521,9879055251,9879055251,9978723201,9978723201,9023090859,9723977510,
    9714419899,9408827076,9510108014,9016921016,9978723201,9727460673,9427759286,9328938519,9824898551,9377163033,9537380101,9714603038
  ];

}

