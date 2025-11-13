import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohmo/db/drift_database.dart';

class GroupChangePasswordBottomSheet extends StatefulWidget {
  final int groupId;
  final String title;

  const GroupChangePasswordBottomSheet({
    Key? key,
    required this.groupId,
    this.title = "비밀번호 변경하기",
  }) : super(key: key);

  @override
  State<GroupChangePasswordBottomSheet> createState() =>
      _GroupChangePasswordBottomSheetState();
}

class _GroupChangePasswordBottomSheetState
    extends State<GroupChangePasswordBottomSheet> {
  final db = LocalDatabaseSingleton.instance;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 42,
          right: 42,
          top: 42,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  '새로 입력한 숫자 4자리로\n비밀번호가 업데이트됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PretendardRegular',
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildPasswordSection(),
              SizedBox(height: 40),
              _buildConfirmButton(),
              SizedBox(height: 15),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '새로운 비밀번호',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'PretendardMedium',
            color: Colors.black,
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          child: Container(
            width: double.infinity,
            height: 49,
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
                    controller: _passwordController,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'PretendardRegular',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(right: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final String password = _passwordController.text;

          if (password.length != 4) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("숫자 4자리를 입력해주세요.")));
            return;
          }

          try {
            await db.updateGroupPassword(widget.groupId, password);

            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("비밀번호가 변경되었습니다\n멤버들에게 공유하세요")));
              Navigator.pop(context, true);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("오류가 발생했습니다: $e")));
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '완료',
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

  Widget _buildCancelButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 327,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardBold',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
