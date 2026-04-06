import 'package:flutter/material.dart';

import '../../models/profile_data_provider.dart';
import '../login/login_screen.dart';
import 'group_enter_room_screen.dart';
import 'group_new_room_screen.dart';
import 'package:provider/provider.dart';

class GroupSignScreen extends StatefulWidget {
  const GroupSignScreen({Key? key}) : super(key: key);

  @override
  _GroupSignScreenState createState() => _GroupSignScreenState();
}

class _GroupSignScreenState extends State<GroupSignScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGuestStatus();
    });
  }

  void _checkGuestStatus() {
    final profile = Provider.of<ProfileData>(context, listen: false);

    if (profile.isGuest) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '\n로그인이 필요한 기능입니다\n',
              style: TextStyle(fontFamily: 'PretendardBold', fontSize: 18),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              '그룹 기능은 게스트 모드에서 이용할 수 없어요.\n로그인하고 멤버들과 일정을 공유해보세요! ✨',
              style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 14),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  '나중에 할게요',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'PretendardMedium',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '로그인하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PretendardBold',
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
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
          MaterialPageRoute(
            builder: (context) => GroupEnterRoomScreen(groupId: 1),
          ),
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
