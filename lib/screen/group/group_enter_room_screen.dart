import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/db/drift_database.dart';

import 'group_final_enter_room_screen.dart';

class GroupEnterRoomScreen extends StatefulWidget {
  final int groupId;

  const GroupEnterRoomScreen({Key? key, required this.groupId})
    : super(key: key);

  @override
  _GroupEnterRoomScreenState createState() => _GroupEnterRoomScreenState();
}

class _GroupEnterRoomScreenState extends State<GroupEnterRoomScreen> {
  final db = LocalDatabaseSingleton.instance;
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordValid = false;
  Timer? _debounce;

  late Future<Group?> _groupFuture;

  @override
  void initState() {
    super.initState();
    _groupFuture = db.getGroupById(widget.groupId);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final id = _passwordController.text.trim();
      if (id.isEmpty) {
        if (mounted) setState(() => _isPasswordValid = false);
        return;
      }
      final bool exists = (id == "1234"); // db 연결 필요

      if (mounted) {
        setState(() {
          _isPasswordValid = exists;
        });
      }
    });
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              SizedBox(height: 60.0),
              _buildNewRoomHeader(),
              SizedBox(height: 30.0),
              _buildRoomName(),
              SizedBox(height: 60.0),
              _buildRoomPassword(_passwordController),
              SizedBox(height: 180.0),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRoomHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            '방 입장하기',
            style: TextStyle(fontFamily: 'PretendardBold', fontSize: 20.0),
          ),
          SizedBox(height: 100),
          Text(
            '입장하려는 방의 이름을 확인하세요',
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomName() {
    return Container(
      width: 214,
      height: 37,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
        ],
      ),
      child: Text(
        textAlign: TextAlign.center,
        '사이드 프로젝트',
        style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 12.0),
      ),
    );
  }

  Widget _buildRoomPassword(TextEditingController controller) {
    return Column(
      children: [
        Text(
          '입장하려는 방의 비밀번호를 입력하세요',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
        ),
        SizedBox(height: 30),
        Container(
          width: 214,
          height: 37,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),

            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 15),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10,left: 30),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'PretendardMedium',
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'android/assets/images/round_check.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _isPasswordValid ? Colors.black : Color(0xFFAFAFAF),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_isPasswordValid) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupFinalEnterRoomScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("비밀번호를 확인해주세요")));
          }
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
              '다음',
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
