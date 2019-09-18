import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_livestream_ml_vision/firebase_livestream_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight]);
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseVision _vision;
  WebViewController _webViewController;
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  String filePath = 'assets/pong/index.html';
//  String filePath = 'assets/test.html';
  double range;

  @override
  void initState() {
    super.initState();
    range = 0.0;
    _initializeCamera();
    _loadJS('pong/p5min');
    _loadJS('pong/sketch');
  }

  void _loadJS(String name) async {
    var givenJS = rootBundle.loadString('assets/$name.js');
    givenJS.then((String js) {
      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.finishLoad) {
          flutterWebviewPlugin.evalJavascript(js);
        }
      });
    });
  }

  void _initializeCamera() async {
    List<FirebaseCameraDescription> cameras = await camerasAvailable();
    _vision = FirebaseVision(cameras[1], ResolutionSetting.high);
    _vision.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _vision.addFaceDetector().then((faces) {
        faces.asBroadcastStream().listen((faces_data) {
          if (faces_data.length != 0) {
            setState(() {
              double dist_in_pix = faces_data[0].boundingBox.right -
                  faces_data[0].boundingBox.left;
              dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
              dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
              range = 1.0 - (dist_in_pix - 250) / (550 - 250);

              print(range);
              flutterWebviewPlugin.evalJavascript('controller($range)');
            });
          }
        });
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String>(
        future: _loadLocalHTML(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return WebviewScaffold(
              withJavascript: true,
              appCacheEnabled: true,
              withLocalUrl: true,
              url: new Uri.dataFromString(snapshot.data, mimeType: 'text/html')
                  .toString(),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }


Future<String> _loadLocalHTML() async {
  return await rootBundle.loadString(filePath);
}

  void dispose() {
    _vision.dispose().then((_) {
      // close all detectors
    });

    super.dispose();
  }
}
