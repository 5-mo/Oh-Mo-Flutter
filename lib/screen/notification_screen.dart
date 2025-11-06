import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontFamily: 'PretendardBold',
          ),
        ),
        centerTitle: false,
        titleSpacing: 3.0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNotificationHeader(),
            SizedBox(height: 60.0),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        textAlign: TextAlign.right,
        "알림 해제는 휴대폰 설정 앱>알림>'OhMo'에서 설정할 수 있습니다",
        style: TextStyle(
          fontFamily: 'PretendardRegular',
          fontSize: 8.0,
          color: Color(0xFF565656),
        ),
      ),
    );
  }
}
