import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ohmo/screen/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 5;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Calender",
      "desc": "한 달/일주일 보기로\n달력을 전환할 수 있어요",
      "image": "android/assets/images/onboarding/onboarding_1.png",
    },
    {
      "title": "Calender",
      "desc": "최소한의 필수 항목만 적어\n간편하고 빠르게 일정을 기록할 수 있어요",
      "image": "android/assets/images/onboarding/onboarding_2.png",
    },
    {
      "title": "Day-Log",
      "desc": "오늘의 기분은 어떠셨나요?\n이번 달 달성률도 체크해보세요",
      "image": "android/assets/images/onboarding/onboarding_3.png",
    },
    {
      "title": "Category",
      "desc": "불필요한 일정은 과감히 지워버리세요\n필요한 것만 나만의 방식으로 관리하세요",
      "image": "android/assets/images/onboarding/onboarding_4.png",
    },
    {
      "title": "Widget",
      "desc": "홈화면과 잠금화면에\n다양한 위젯을 추가해보세요!",
      "image": "android/assets/images/onboarding/onboarding_5.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color:
                          index <= _currentPage
                              ? Color(0xFF2A2A2A)
                              : Color(0xFFEBEBEB),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        textAlign: TextAlign.left,
                        onboardingData[index]["title"]!,
                        style: const TextStyle(
                          fontSize: 35,
                          fontFamily: 'RubikSprayPaint',
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]["desc"]!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          height: 1.3,
                          fontFamily: 'PretendardSemibold',
                        ),
                      ),
                  const SizedBox(height: 30),
                  Center(
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            width: 340,
                            height: 460,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (_currentPage < _totalSteps - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isFirstTime', false);

                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                child: Container(
                  width: 272,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == _totalSteps - 1
                            ? Colors.black
                            : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _currentPage == _totalSteps - 1 ? '시작하기' : "다음",
                    style: const TextStyle(
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
    );
  }
}
