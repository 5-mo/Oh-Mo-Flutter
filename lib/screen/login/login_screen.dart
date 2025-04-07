import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/screen/login/email_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 553,
                  left: 17,
                  child: Column(
                    children: [
                      _buildGoogleLogin(),
                      SizedBox(height: 13),
                      _buildNaverLogin(),
                      SizedBox(height: 13),
                      _buildKakaoLogin(),
                      SizedBox(height: 13),
                      _buildEmailLogin(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLogin() {
    return Container(
      width: 360,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),

      child: Center(
        child: Center(
          child: Row(
            children: [
              SizedBox(width: 20.0),
              SvgPicture.asset('android/assets/images/login_google.svg'),
              SizedBox(width: 90.0),
              Text(
                'Google로 시작하기',
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNaverLogin() {
    return Container(
      width: 360,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Color(0xFF00BF18),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),

      child: Center(
        child: Center(
          child: Row(
            children: [
              SizedBox(width: 20.0),
              SvgPicture.asset('android/assets/images/login_naver.svg'),
              SizedBox(width: 97.0),
              Text(
                '네이버로 시작하기',
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoLogin() {
    return Container(
      width: 360,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Color(0xFFFAE84C),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
        ],
      ),

      child: Center(
        child: Center(
          child: Row(
            children: [
              SizedBox(width: 20.0),
              SvgPicture.asset('android/assets/images/login_kakao.svg'),
              SizedBox(width: 97.0),
              Text(
                '카카오로 시작하기',
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailLogin(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmailScreen()),
        );
      },
      child: Text(
        '이메일로 로그인',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'PretendardRegular',
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
