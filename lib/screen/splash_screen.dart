import 'package:flutter/material.dart';
import 'package:ohmo/screen/login/login_screen.dart';
import 'package:ohmo/screen/initial_screen_decider.dart';
import 'package:ohmo/services/auth_service.dart';
import 'package:video_player/video_player.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // 1. 여기서 토큰 체크를 진행합니다.
    final token = await AuthService.refreshToken();

    if (!mounted) return;

    if (token != null) {
      _navigateToMain();
    } else {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
      print("자동 로그인 실패: 수동 로그인 필요");
    }
  }

  void _navigateToMain() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InitialScreenDecider()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 이미지
              Image.asset('android/assets/images/splash.png', width: 293),

              const Spacer(flex: 5),

              // 시작하기 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Container(
                      width: 272,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'PretendardBold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
