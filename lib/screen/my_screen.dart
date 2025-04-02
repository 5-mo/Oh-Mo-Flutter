import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:ohmo/screen/profile_screen.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int _selectedIndex = 2;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DaylogScreen()),
        );
      }
    });
  }

  bool _showSearchRecords = false;
  final List<Map<String, String>> _searchRecords = [
    {'text': '오모 회식', 'date': '2025.02.02'},
    {'text': '미팅 일정', 'date': '2025.03.02'},
    {'text': '운동 계획', 'date': '2025.02.22'},
    {'text': '공부', 'date': '2025.03.22'},
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  child: SvgPicture.asset(
                    'android/assets/images/mybackground.svg',
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                  ),
                ),

                Positioned(
                  top: 66,
                  left: 41,
                  child: Row(
                    children: [
                      SvgPicture.asset('android/assets/images/myprofile.svg'),
                      SizedBox(width: 50),
                      _buildProfileSection(context),
                    ],
                  ),
                ),
                Positioned(
                  left: 38,
                  top: 367,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotionButton(context),
                      SizedBox(height: 20.0),
                      _buildCategoryManaging(context),
                      SizedBox(height: 10.0),
                      _buildDiaryCollection(context),
                    ],
                  ),
                ),
                Positioned(
                  left: 50,
                  top: 186,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchbarSection(context),
                      _buildSearchbarRecords(context),
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

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        Text('오모', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        Text(
          'jwjwhvv@gamil.com',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        SizedBox(height: 10.0),
        _buildProfileButton(context),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
      child: Container(
        width: 87,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(
            '프로필 수정',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'PretendardRegular',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchbarSection(BuildContext context) {
    return Container(
      height: 31,
      width: 311,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          SizedBox(width: 40.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'PretendardRegular',
              ),
              decoration: InputDecoration(
                hintText: '일정 검색',
                hintStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                ),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              onTap: () {
                setState(() {
                  _showSearchRecords = true;
                });
              },
              onChanged: (text) {
                setState(() {
                  _showSearchRecords = text.isNotEmpty;
                });
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              print("검색");
            },
            child: Icon(Icons.search, color: Colors.white),
          ),
          SizedBox(width: 10.0),
        ],
      ),
    );
  }

  Widget _buildSearchbarRecords(BuildContext context) {
    return Visibility(
      visible: _showSearchRecords,
      child: Container(
        width: 311,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Middle_GREY_COLOR),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_searchRecords.length * 2 - 1, (index) {
            if (index.isEven) {
              final record = _searchRecords[index ~/ 2];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            body: DaylogScreen(date: record['date']!),
                            bottomNavigationBar: OhmoBottomNavigationBar(
                              selectedIndex: 1,
                              onTabChange: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                  if (index == 0) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                    );
                                  } else if (index == 2) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyScreen(),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record['text']!,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        record['date']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Middle_GREY_COLOR,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Divider(color: Colors.grey);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildNotionButton(BuildContext context) {
    return Container(
      width: 311,
      height: 44,
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
              SvgPicture.asset('android/assets/images/notion.svg'),
              SizedBox(width: 30.0),
              Text(
                'Notion 연결 및 업데이트',
                style: TextStyle(fontSize: 18, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryManaging(BuildContext context) {
    return Text(
      "카테고리 관리",
      style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
    );
  }

  Widget _buildDiaryCollection(BuildContext context) {
    return Text(
      "일기 모아보기",
      style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
    );
  }
}
