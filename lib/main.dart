import 'package:colosseum/util.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
//  await SystemChrome.setPreferredOrientations(
//      [DeviceOrientation.landscapeRight]);
//  SystemChrome.setEnabledSystemUIOverlays([]);

  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    //logError(e.code, e.description);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  String filePath = 'assets/pong/index.html';
//  String filePath = 'assets/test.html';
  double range;
  bool ready_for_next_image = true;

  @override
  void initState() {
    super.initState();
    range = 0.0;
    _initializeCamera();
    _loadJS('pong/p5min');
    _loadJS('pong/sketch');
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(
      description,
      ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (!ready_for_next_image) {
        return;
      }
      setState(() {
        ready_for_next_image = false;
      });

      detect(image, faceDetector.processImage, rotation).then(
        (dynamic faces) {
          if (faces.length != 0) {
            double dist_in_pix =
                faces[0].boundingBox.right - faces[0].boundingBox.left;
            dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
            dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
            setState(() {
              range = 1.0 - (dist_in_pix - 250) / (550 - 250);
            });
            flutterWebviewPlugin.evalJavascript('controller($range)');
          } 
          ready_for_next_image = true;
        },
      );
    });
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
    _camera?.dispose();
    faceDetector.close();

    super.dispose();
  }
}
