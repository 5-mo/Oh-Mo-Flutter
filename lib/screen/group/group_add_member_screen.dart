import 'package:flutter/material.dart';

class GroupAddMemberScreen extends StatefulWidget {
  const GroupAddMemberScreen({Key? key}) : super(key: key);

  @override
  _GroupAddMemberScreenState createState() => _GroupAddMemberScreenState();
}

class _GroupAddMemberScreenState extends State<GroupAddMemberScreen> {
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
            SizedBox(height: 60.0),
            _buildSharingHeader(),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Let\'s Go!',
            style: TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Text(
            '새로운 그룹을 만들었어요!\n함께하고 싶은 멤버들을 초대해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 14.0),
          ),
          SizedBox(height: 40),
          Image.asset('android/assets/images/ohmo_letsgo.png', width: 200),
        ],
      ),
    );
  }

}
