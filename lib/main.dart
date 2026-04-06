// ignore_for_file: depend_on_referenced_packages, use_super_parameters, unused_import

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: prefer_const_constructors
      home: MainPage(),
    );
  }
}
