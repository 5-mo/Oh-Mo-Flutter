import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ohmo/screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearTokens() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  print('토큰 삭제 완료 (자동 로그인 해제)');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.setAppGroupId('group.ohmo');
  await clearTokens();
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
