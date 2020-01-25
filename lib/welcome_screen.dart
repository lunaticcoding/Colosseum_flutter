import 'package:colosseum/controller/pushup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller/Game.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('play'),
              onPressed: () {
                Navigator.pushNamed(context, PushupController.id,
                  arguments: Game(
                    path: 'assets/impossibleGame/',
                    htmlFile: 'index.html',
                    jsFiles: ['p5.min.js', 'obstacle.js', 'game.js'],
                    orientation: DeviceOrientation.landscapeLeft,
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text('test'),
              onPressed: () {
                Navigator.pushNamed(context, PushupController.id,
                    arguments: Game(
                        path: 'assets/',
                        htmlFile: 'test.html',
                        jsFiles: [],
                        orientation: DeviceOrientation.landscapeLeft,
                    ),
                );
              },
            ),
          ],
        )
      )
    );
  }
}
