import 'package:flutter/material.dart';
import 'package:ohmo/screen/home_screen.dart';
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home:HomeScreen(),
    ),
  );
}

