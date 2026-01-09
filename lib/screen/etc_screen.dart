import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/screen/etc/alarm_setting.dart';
import 'package:ohmo/screen/etc/community_guildeline.dart';
import 'package:ohmo/screen/etc/opensource_license.dart';
import 'package:ohmo/screen/etc/private_information.dart';

import 'etc/faq.dart';
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
                  _buildLeave(context),
                  const SizedBox(height: 30.0),
                  Center(child:
                    _buildVersion()),
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
          MaterialPageRoute(builder: (context) => AlarmSettingScreen()),
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
          MaterialPageRoute(builder: (context) => AlarmSettingScreen()),
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
          MaterialPageRoute(builder: (context) => AlarmSettingScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '회원 탈퇴',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular',color: Color(0xFFE7000B)),
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


  Widget _buildVersion() {
    return Text(
      '버전 1.0.0',
      style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 10.5,color: Color(0xFF6A7282)),
    );
  }
}
