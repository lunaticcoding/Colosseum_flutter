import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_livestream_ml_vision/firebase_livestream_ml_vision.dart';
import 'package:flutter/services.dart';
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
  String filePath = 'assets/pong/index.html';
//  String filePath = 'assets/test.html';
  double range;

  @override
  void initState() {
    super.initState();
    range = 0.0;
    _initializeCamera();
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
              dist_in_pix = (dist_in_pix > 600) ? 600 : dist_in_pix;
              dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
              range = 1.0 - (dist_in_pix - 250) / (600 - 250);

              print(range);
              _webViewController.evaluateJavascript('controller($range)');

            });
          }
        });
      });
      setState(() {});
    });
  }

  void _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 2,
      child: WebView(

        initialUrl: filePath,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          _loadHtmlFromAssets();
        },
      ),
    );
  }

  void dispose() {
    _vision.dispose().then((_) {
      // close all detectors
    });

    super.dispose();
  }
}
