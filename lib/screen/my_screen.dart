import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/screen/profile_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ohmo/profile_data_provider.dart';
import 'package:ohmo/screen/category_screen.dart';

class MyScreen extends StatefulWidget {
  final Function(int) onTabChange;
  final ValueNotifier<DateTime> selectedDateNotifier;

  MyScreen({required this.onTabChange, required this.selectedDateNotifier});

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _showSearchRecords = false;

  final List<Map<String, String>> _searchRecords = [
    {'text': '오모 회식', 'date': '2025.02.02'},
    {'text': '미팅 일정', 'date': '2025.03.02'},
    {'text': '운동 계획', 'date': '2025.02.22'},
    {'text': '공부', 'date': '2025.03.22'},
  ];

  final TextEditingController _searchController = TextEditingController();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<ProfileData>(
        context,
        listen: false,
      ).updateProfile(updateImage: File(pickedFile.path));
    } else {
      print('이미지를 선택하지 않았습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileData>(context);

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
                      GestureDetector(
                        onTap: () => _pickImage(context),
                        child:
                            profile.image != null
                                ? ClipOval(
                                  child: Image.file(
                                    profile.image!,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : SvgPicture.asset(
                                  'android/assets/images/myprofile.svg',
                                ),
                      ),

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
    final profile = Provider.of<ProfileData>(context);
    return Column(
      children: [
        Text(
          profile.nickname,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        Text(
          profile.email,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        SizedBox(height: 10.0),
        _buildProfileButton(context),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final profile = Provider.of<ProfileData>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
                  initialImage: profile.image,
                  initialNickname: profile.nickname,
                  initialEmail: profile.email,
                ),
          ),
        );

        profile.updateProfile(
          updateImage: result?['image'],
          updateNickname: result?['nickname'],
          updateEmail: result?['email'],
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
                  final date = DateFormat('yyyy.MM.dd').parse(record['date']!);
                  widget.selectedDateNotifier.value = date;
                  widget.onTabChange(1);
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen()),
        );
      },
      child: Text(
        '카테고리 관리',
        style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
      ),
    );
  }

  Widget _buildDiaryCollection(BuildContext context) {
    return Text(
      "일기 모아보기",
      style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
    );
  }
}
