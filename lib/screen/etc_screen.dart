import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/screen/etc/alarm_setting.dart';
import 'package:ohmo/screen/etc/community_guildeline.dart';
import 'package:ohmo/screen/etc/opensource_license.dart';
import 'package:ohmo/screen/etc/private_information.dart';
import 'package:ohmo/screen/login/login_screen.dart';
import 'package:provider/provider.dart';

import '../models/profile_data_provider.dart';
import '../services/auth_service.dart';
import 'etc/bug.dart';
import 'etc/faq.dart';
import 'etc/inquire.dart';
import 'etc/leave.dart';
import 'etc/service.dart';

class EtcScreen extends StatefulWidget {
  const EtcScreen({super.key});

  @override
  State<EtcScreen> createState() => _EtcScreenState();
}

class _EtcScreenState extends State<EtcScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileData>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'android/assets/images/left.svg',
            width: 20,
            height: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEtcHeader(),
                  const SizedBox(height: 40.0),
                  _buildAlarmSetting(context),
                  const SizedBox(height: 15.0),
                  _buildService(context),
                  const SizedBox(height: 15.0),
                  _buildPrivateInformation(context),
                  const SizedBox(height: 15.0),
                  _buildCommunityGuideline(context),
                  const SizedBox(height: 15.0),
                  _buildOpensourceLicense(context),
                  const SizedBox(height: 15.0),
                  _buildFAQ(context),
                  const SizedBox(height: 15.0),
                  _buildInquire(context),
                  const SizedBox(height: 15.0),
                  _buildBug(context),
                  const SizedBox(height: 15.0),
                  if (!profile.isGuest) ...[
                    _buildLeave(context),
                    const SizedBox(height: 15.0),
                    _buildLogout(context),
                    const SizedBox(height: 15.0),
                  ],
                  Center(child: _buildVersion()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtcHeader() {
    return Text(
      '기타',
      style: TextStyle(fontFamily: 'PretendardBold', fontSize: 18.0),
    );
  }

  Widget _buildAlarmSetting(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlarmSettingScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '알림 설정',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildService(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServiceScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '서비스 이용약관',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateInformation(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrivateInformationScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '개인정보 처리방침',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityGuideline(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CommunityGuildelineScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '커뮤니티 가이드라인',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildOpensourceLicense(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OpenSourceLicenseScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '오픈소스 라이선스',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaqScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '자주 묻는 질문 (FAQ)',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildInquire(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InquireScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '문의하기',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildBug(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BugScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '신고하기',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLeave(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LeaveScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '회원 탈퇴',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'PretendardRegular',
              color: Color(0xFFE7000B),
            ),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _showLogoutDialog(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '로그아웃',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
          SvgPicture.asset(
            'android/assets/images/right.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "로그아웃하시겠습니까?",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "로그아웃해도 이전 일정 기록들은\n삭제되지 않습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 35),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: 120,
                      height: 51,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'PretendardBold',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(120, 51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await AuthService.logout();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      "로그아웃",
                      style: TextStyle(
                        fontFamily: 'PretendardBold',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersion() {
    return Text(
      '버전 1.0.0',
      style: TextStyle(
        fontFamily: 'PretendardRegular',
        fontSize: 10.5,
        color: Color(0xFF6A7282),
      ),
    );
  }
}
