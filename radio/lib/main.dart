import 'package:flutter/material.dart';
import 'package:radio/screens/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'cuber',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'cuber'),
    );
  }
}
