import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/screen/login/signup_screen.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:provider/provider.dart';
import '../../models/profile_data_provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Row(
                children: [
                  SizedBox(width: 90),
                  Image.asset(
                    'android/assets/images/clear_ohmo.png',width: 53,
                  ),
                  SizedBox(width: 20),
                  Center(
                    child: Text(
                      'OhMo',
                      style: TextStyle(
                        fontFamily: 'RubikSprayPaint',
                        fontSize: 36.0,
                      ),
                    ),
                  ),
          ],
        ),
                  SizedBox(height: 60),
                  _buildTextField('이메일 주소', false, _emailController),
                  SizedBox(height: 30),
                  _buildTextField('비밀번호', true, _passwordController),
                  SizedBox(height: 20),
                  _buildSignup(context),
                  SizedBox(height: 40),
                  _buildLoginButton(),
                  SizedBox(height: 30),

                  /*_buildGoogleLogin(),
              SizedBox(height: 13),
              _buildNaverLogin(),
              SizedBox(height: 13),
              _buildKakaoLogin(),
              SizedBox(height: 13),*/
              _buildGuestMode(context),
              SizedBox(height: 200),
              Text(
                '로그인 시 개인정보 처리방침을 읽었으며, 이용약관에 동의하신 것으로 간주합니다.',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'PretendardMedium',
                  color: Color(0xFFC2C2C2),
                ),
              ),
                ],
              ),
          ),
        ),
    );
  }

  Widget _buildTextField(
    String hint,
    bool obscure,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: LIGHT_GREY_COLOR,
            fontFamily: 'PretendardBold',
            fontSize: 16,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
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
                'Google로 로그인 하기',
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
                '네이버로 로그인 하기',
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
              SizedBox(width: 88.0),
              Text(
                '카카오로 로그인 하기',
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignup(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
      },
      child: Text(
        '회원가입',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'PretendardRegular',
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () async {
        final email = _emailController.text;
        final password = _passwordController.text;

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')));
          return;
        }
        final response = await AuthService.login(email, password);

        if (response != null) {
          print('로그인 성공');
          print('Access Token: ${response['token']['accessToken']}');

          final profile = Provider.of<ProfileData>(context, listen: false);
          profile.updateProfile(
            updateEmail: email,
            updateNickname: response['nickname'],
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('로그인에 실패했습니다.')));
        }
      },
      child: Container(
        width: 140,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            '로그인',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestMode(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>HomeScreen()),
        );
      },
      child: Text(
        '둘러보기',
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'PretendardRegular',
          color: Color(0xFF808080),
        ),
      ),
    );
  }
}
