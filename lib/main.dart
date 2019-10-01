import 'package:colosseum/counterScreen.dart';
import 'package:colosseum/controller/pushup_controller.dart';
import 'package:colosseum/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(ColosseumApp());

class ColosseumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        PushupController.id: (context) => PushupController(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
      },
    );
  }
}