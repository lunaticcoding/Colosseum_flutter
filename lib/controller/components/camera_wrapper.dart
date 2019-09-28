import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

typedef HandleDetection = Future<dynamic> Function(FirebaseVisionImage image);
List<CameraDescription> cameras;

class CameraWrapper {
  CameraController _camera;
  CameraLensDirection _direction = CameraLensDirection.front;
  bool isDetectingFace = true;

  void initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      //logError(e.code, e.description);
    }
  }

  void dispose() {
    _camera?.dispose();
  }

  void initializeCamera(Function runFaceDetection, Function onFaceDetected) async {
    CameraDescription description = await _getCamera(_direction);
    ImageRotation rotation = _rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(
      description,
      ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (!isDetectingFace) {
        return;
      }

      isDetectingFace = false;

      _detect(image, runFaceDetection, rotation).then(
            (dynamic faces) {
              onFaceDetected(faces);
          isDetectingFace = true;
        },
      );
    });
  }

  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  Future<dynamic> _detect(
      CameraImage image,
      HandleDetection handleDetection,
      ImageRotation rotation,
      ) async {
    return handleDetection(
      FirebaseVisionImage.fromBytes(
        _concatenatePlanes(image.planes),
        _buildMetaData(image, rotation),
      ),
    );
  }

  ImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }
  FirebaseVisionImageMetadata _buildMetaData(
      CameraImage image,
      ImageRotation rotation,
      ) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map(
            (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

}