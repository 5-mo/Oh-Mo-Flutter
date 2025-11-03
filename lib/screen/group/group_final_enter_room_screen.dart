import 'package:flutter/material.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';

import '../../const/colors.dart';

class GroupFinalEnterRoomScreen extends StatefulWidget {
  final int groupId;

  const GroupFinalEnterRoomScreen({Key? key, required this.groupId})
    : super(key: key);

  @override
  _GroupFinalEnterRoomScreenState createState() =>
      _GroupFinalEnterRoomScreenState();
}

class _GroupFinalEnterRoomScreenState extends State<GroupFinalEnterRoomScreen> {
  final TextEditingController _nicknameController = TextEditingController();

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
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60.0),
            _buildInvitedHeader(),
            SizedBox(height: 113.0),
            _buildNickname(),
            SizedBox(height: 10.0),
            _buildNicknameTextField(_nicknameController),
            SizedBox(height: 55.0),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitedHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Let\'s Go!',
            style: TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Text(
            '새로운 그룹에 들어왔어요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 14.0),
          ),
          SizedBox(height: 40),
          Image.asset('android/assets/images/ohmo_letsgo.png', width: 200),
        ],
      ),
    );
  }

  Widget _buildNickname() {
    return Center(
      child: Column(
        children: [
          Text(
            '닉네임을 설정하세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameTextField(TextEditingController controller) {
    return Container(
      width: 168,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,

          prefixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.transparent,
                      size: 14,
                    ),
                    onPressed: null,
                  )
                  : null,

          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.cancel, color: ICON_GREY_COLOR, size: 14),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  )
                  : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupMainScreen(groupId: 1),
            ),
          );
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '입장하기',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
