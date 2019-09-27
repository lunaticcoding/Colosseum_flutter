import 'package:colosseum/camera_custom.dart';
import 'package:colosseum/util.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:camera/camera.dart';
import 'camera_custom.dart';

dynamic camera = CameraWrapper();

Future<void> main() async {
//  await SystemChrome.setPreferredOrientations(
//      [DeviceOrientation.landscapeRight]);
//  SystemChrome.setEnabledSystemUIOverlays([]);

  camera.initCamera();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
//  String filePath = 'assets/pong/index.html';
  String filePath = 'assets/test.html';
  double range;


  @override
  void initState() {
    super.initState();
    range = 0.0;
    camera.initializeCamera(
      faceDetector.processImage,
        onFaceDetected
    );
//    _loadJS('pong/p5min');
//    _loadJS('pong/sketch');
  }

  void onFaceDetected(dynamic faces) {
    if (faces.length != 0) {
      double dist_in_pix =
          faces[0].boundingBox.right - faces[0].boundingBox.left;
      dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
      dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
      double range = 1.0 - (dist_in_pix - 250) / (550 - 250);
      flutterWebviewPlugin.evalJavascript('controller($range)');
    }
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
    camera.dispose();
    faceDetector.close();

    super.dispose();
  }
}
