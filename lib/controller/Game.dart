import 'package:flutter/services.dart';

class Game {
  final String path;
  final String htmlFile;
  final List<String> jsFiles;
  final DeviceOrientation orientation;

  Game({this.path, this.htmlFile, this.jsFiles, this.orientation});
}