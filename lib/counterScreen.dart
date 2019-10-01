import 'package:flutter/material.dart';

class CounterScreen extends StatelessWidget {
  final int counter;

  CounterScreen({this.counter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$counter'),
    );
  }
}
