import 'package:colosseum/controller/pushup_controller.dart';
import 'package:flutter/material.dart';

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
        child: RaisedButton(
          child: Text('play'),
          onPressed: () {
            Navigator.pushNamed(context, PushupController.id);
          },
        ),
      )
    );
  }
}
