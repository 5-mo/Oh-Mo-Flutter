import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:ohmo/profile_data_provider.dart';
import 'package:ohmo/screen/login/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileData(),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
