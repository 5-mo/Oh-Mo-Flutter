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
  late VideoPlayerController _controller;
  bool _isVideoFinished = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _initializedVideo();

  }

  Future<void> _initializedVideo() async {
    _controller = VideoPlayerController.asset('android/assets/omo.mp4');

    try {
      await _controller.initialize();
      setState(() {});
      _controller.play();

      _controller.addListener(() {
        if (_controller.value.isInitialized &&
            _controller.value.position > Duration.zero &&
            _controller.value.position >= _controller.value.duration) {

          if (_isLoggedIn) {
            _navigateToMain();
          } else if (!_isVideoFinished) {
            setState(() {
              _isVideoFinished = true;
            });
          }
        }
      });
    } catch (e) {
      print("비디오 로드 에러: $e");
      setState(() { _isVideoFinished = true; });
    }
  }

  Future<void> _checkToken() async {
    final token = await AuthService.refreshToken();

    if (!mounted) return;

    if (token != null) {
      _isLoggedIn = true;
      if (_isVideoFinished) {
        _navigateToMain();
      }
    } else {
      _isLoggedIn = false;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_isVideoFinished)
            Center(
              child:
                  _controller.value.isInitialized
                      ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                      : Container(),
            ),
          if (_isVideoFinished) ...[
            Positioned(
              top: 150,
              left: 50,
              child: Image.asset(
                'android/assets/images/splash.png',
                width: 293,
              ),
            ),
            Positioned(
              top: 670,
              left: 60,
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
                      shape: BoxShape.rectangle,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
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
        ],
      ),
    );
  }
}
