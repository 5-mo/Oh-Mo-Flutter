import 'package:flutter/material.dart';
import 'package:ohmo/screen/login/login_screen.dart';
import 'package:ohmo/screen/initial_screen_decider.dart';
import 'package:ohmo/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  double _opacity = 0.5;

  @override
  void initState() {
    super.initState();
    _checkToken();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  Future<void> _checkToken() async {
    try {
      final token = await AuthService.refreshToken().timeout(
        const Duration(seconds: 5),
      );

      if (!mounted) return;

      if (token != null) {
        _navigateToMain();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      _navigateToMain();
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
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeIn,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox.expand(
            child: Column(
              children: [
                const Spacer(flex: 2),

                Image.asset('android/assets/images/splash.png', width: 293),

                const Spacer(flex: 5),

                // 시작하기 버튼
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final bool isFirstTime =
                            prefs.getBool('isFirstTime') ?? true;

                        if (!mounted) return;

                        if (isFirstTime) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnBoardingScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        }
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
      ),
    );
  }
}
