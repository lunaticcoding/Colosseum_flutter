import 'package:colosseum/controller/components/camera_wrapper.dart';
import 'package:colosseum/controller/components/local_file_webview.dart';
import 'package:colosseum/counterScreen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'Game.dart';
import 'components/camera_wrapper.dart';

dynamic camera = CameraWrapper();

class PushupController extends StatefulWidget {
  static String id = 'PushupController';

  PushupController({Key key}) : super(key: key);

  @override
  _PushupControllerState createState() => _PushupControllerState();
}

class _PushupControllerState extends State<PushupController> {
  FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  Game game;

  bool isJumpDone = false;
  bool isGameOver = false;
  double range;
  int counter = 0;

  void onFaceDetected(dynamic faces) {
    flutterWebviewPlugin.evalJavascript('isGameOver();').then((isGameOver) {
      if (isGameOver.toLowerCase() == 'true') {
        flutterWebviewPlugin.close();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CounterScreen(counter: counter),
          ),
        );
      }
    });

    if (faces.length != 0) {
      double dist_in_pix =
          faces[0].boundingBox.right - faces[0].boundingBox.left;
      print(dist_in_pix);
      dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
      dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
      double range = 1.0 - (dist_in_pix - 250) / (550 - 250);
      print(range);
      if (range < 0.8) {
        if (!isJumpDone) {
          counter++;
          flutterWebviewPlugin.evalJavascript('controller($range)');
          isJumpDone = true;
        }
      } else {
        isJumpDone = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    game = ModalRoute.of(context).settings.arguments;
    initScreen(game.orientation);

    return MaterialApp(
      home: LocalFileWebview(
        flutterWebviewPlugin: flutterWebviewPlugin,
        path: game.path,
        htmlFile: game.htmlFile,
        jsFiles: game.jsFiles,
      ),
    );
  }

  void initScreen(DeviceOrientation orientation) {
    SystemChrome.setPreferredOrientations([orientation]).then((_) {
      SystemChrome.setEnabledSystemUIOverlays([]).then((_) {
        range = 0.0;
        camera.initializeCamera(faceDetector.processImage, onFaceDetected);
      });
      setState(() {}); // to force rerender
    });
  }

  void dispose() {
    camera.dispose();
    faceDetector.close();
    super.dispose();
  }
}
