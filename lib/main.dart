import 'package:colosseum/trex/logic/Game.dart';
import 'package:colosseum/trex/trexgame.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_livestream_ml_vision/firebase_livestream_ml_vision.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

Future<void> main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight]);
  SystemChrome.setEnabledSystemUIOverlays([]);
  Flame.audio.disableLog();
  List<ui.Image> image = await Flame.images.loadAll(["sprite.png"]);
  TRexGame tRexGame = TRexGame(spriteImage: image[0]);

  runApp(MyApp(tRexGame: tRexGame,));

//  Flame.util.
//  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
//    ..onTapDown = (TapDownDetails evt) => tRexGame.onTap());
}


class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseVision _vision;
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
              // tRexGame.onValueUpdate(range);
            });
          }
        });
      });
      setState(() {});
    });
  }

  void dispose() {
    _vision.dispose().then((_) {
      // close all detectors
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 2,
      child: Container(),
    );
  }
}
