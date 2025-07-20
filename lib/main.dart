import 'package:flutter/material.dart';
import 'package:ohmo/screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/profile_data_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileData()),
      ],
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: Splash(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
