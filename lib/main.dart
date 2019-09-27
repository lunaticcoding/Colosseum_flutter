import 'dart:convert';
import 'dart:io';

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
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  //FirebaseVision _vision;
  FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
//  String filePath = 'assets/pong/index.html';
  String filePath = 'assets/test.html';
  double range;
  String demo = "no";
  bool ready_for_next_image = true;

  @override
  void initState() {
    super.initState();
    range = 0;
    _initializeCamera();
//    _camera = CameraController(cameras[1], ResolutionPreset.medium);
//    _camera.initialize().then((_) async {
//      if (!mounted) {
//        return;
//      }
//      setState(() {});
//      _camera.startImageStream((CameraImage availableImage) async {
////        print(availableImage);
//        print("DUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
////        if (flutterWebviewPlugin != null) {
////          flutterWebviewPlugin.evalJavascript('controller($range)');
////        }
////        final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
////            rawFormat: availableImage.format.raw,
////            size: Size(
////                availableImage.width.toDouble(), availableImage.height.toDouble()),
////            planeData: availableImage.planes
////                .map((currentPlane) => FirebaseVisionImagePlaneMetadata(
////                bytesPerRow: currentPlane.bytesPerRow,
////                height: currentPlane.height,
////                width: currentPlane.width))
////                .toList(),
////            rotation: ImageRotation.rotation90);
////
////        final FirebaseVisionImage visionImage =
////        FirebaseVisionImage.fromBytes(availableImage.planes[0].bytes, null);
//        print(availableImage.format);
//
////        final List<Face> faces = await faceDetector.processImage(visionImage);
////        setState(() {
////          range = faces.length.toDouble();
////        });
//      });
//    });
////    range = 0.0;
////    _initializeCamera();
////    _loadJS('pong/p5min');
////    _loadJS('pong/sketch');
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if(!ready_for_next_image){
        return;
      }
      setState(() {
        ready_for_next_image = false;
      });

      detect(image, faceDetector.processImage, rotation).then(
            (dynamic result) {
          setState(() {
            demo = result.toString();
            ready_for_next_image = true;
          });


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

//  void _initializeCamera() async {
//    List<FirebaseCameraDescription> cameras = await camerasAvailable();
//    _vision = FirebaseVision(cameras[1], ResolutionSetting.medium);
//    _vision.initialize().then((_) {
//      if (!mounted) {
//        return;
//      }
//      _vision.addFaceDetector().then((faces) {
//        faces.asBroadcastStream().listen((faces_data) {
//          if (faces_data.length != 0) {
//            setState(() {
//              double dist_in_pix = faces_data[0].boundingBox.right -
//                  faces_data[0].boundingBox.left;
//              dist_in_pix = (dist_in_pix > 550) ? 550 : dist_in_pix;
//              dist_in_pix = (dist_in_pix < 250) ? 250 : dist_in_pix;
//              range = 1.0 - (dist_in_pix - 250) / (550 - 250);
//
//              print(range);
//              flutterWebviewPlugin.evalJavascript('controller($range)');
//            });
//          }
//        });
//      });
//      setState(() {});
//    });
//  }

  Widget _cameraPreviewWidget() {
    if (_camera == null || !_camera.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: _camera.value.aspectRatio,
        child: CameraPreview(_camera),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      home: FutureBuilder<String>(
//        future: _loadLocalHTML(),
//        builder: (context, snapshot) {
//          if (snapshot.hasData) {
//            return WebviewScaffold(
//              withJavascript: true,
//              appCacheEnabled: true,
//              withLocalUrl: true,
//              url: new Uri.dataFromString(snapshot.data, mimeType: 'text/html')
//                  .toString(),
//            );
//          } else if (snapshot.hasError) {
//            return Scaffold(
//              body: Center(
//                child: Text("${snapshot.error}"),
//              ),
//            );
//          }
//          return Scaffold(
//            body: Center(child: CircularProgressIndicator()),
//          );
//        },
//      ),
      home: Text('$demo'),
    );
  }

  Future<String> _loadLocalHTML() async {
    return await rootBundle.loadString(filePath);
  }

  void dispose() {
//    _vision.dispose().then((_) {
//      // close all detectors
//    });
    _camera?.dispose();
    faceDetector.close();

    super.dispose();
  }
}
