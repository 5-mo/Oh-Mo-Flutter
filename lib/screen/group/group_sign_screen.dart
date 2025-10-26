import 'package:flutter/material.dart';

import 'group_enter_room_screen.dart';
import 'group_new_room_screen.dart';

class GroupSignScreen extends StatefulWidget {
  const GroupSignScreen({Key? key}) : super(key: key);

  @override
  _GroupSignScreenState createState() => _GroupSignScreenState();
}

class _GroupSignScreenState extends State<GroupSignScreen> {
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
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCategoryHeader(),
            SizedBox(height: 60.0),
            _buildNewRoom(),
            SizedBox(height: 20.0),
            _buildEnterRoom(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Create your Group',
            style: TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Text(
            '함께 하면 더 쉬운 일정 관리✨\n그룹을 생성하고 멤버들과 할 일을 나눠보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 14.0),
          ),
          SizedBox(height: 25),
          Image.asset('android/assets/images/group_sign.png', width: 300),
        ],
      ),
    );
  }

  Widget _buildNewRoom() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupNewRoomScreen()),
        );
      },
      child: Container(
        width: 318,
        height: 71,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '새로운 방 만들기',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardSemibold',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1),
              Text(
                '방을 만들면 내가 방장이 됩니다',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFF868686),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterRoom() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupEnterRoomScreen()),
        );
      },
      child: Container(
        width: 318,
        height: 71,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),

        child: Center(
          child: Column(
            children: [
              SizedBox(height: 15),
              Text(
                '방 입장하기',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardSemibold',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1),
              Text(
                '방장이 초대하여 멤버가 됩니다',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFF868686),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
