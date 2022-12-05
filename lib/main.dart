import 'package:dusty/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async{
  await dotenv.load(fileName:'.env');
  runApp(
    MaterialApp(
      theme: ThemeData(fontFamily: 'Sunflower'),
      home: HomeScreen(),
    ),
  );
}
