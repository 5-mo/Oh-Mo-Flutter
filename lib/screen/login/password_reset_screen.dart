import 'package:flutter/material.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:ohmo/services/auth_service.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _renewPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '취소',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'PretendardBold',
              fontSize: 16,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                        fontFamily: 'PretendardSemibold',
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  _buildSignupText('현재 비밀번호'),
                  SizedBox(height: 10),
                  _buildTextField(_currentPasswordController),
                  SizedBox(height: 20),
                  _buildSignupText('새로운 비밀번호'),
                  SizedBox(height: 10),
                  _buildTextField(_newPasswordController, isPassword: true),
                  SizedBox(height: 20),
                  _buildSignupText('새로운 비밀번호를 다시 입력하세요'),
                  SizedBox(height: 10),
                  _buildTextField(_renewPasswordController, isPassword: true),
                  SizedBox(height: 40),
                  _buildSignupButton(),
                  SizedBox(height: 300),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset('android/assets/images/omo.png', width: 250),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupText(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PretendardBold',
            fontSize: 16,
            color: Color(0xFF575757),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      width: 340,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.cancel, color: Colors.grey, size: 14),
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

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: () async {
        final currentPassword = _currentPasswordController.text;
        final newPassword = _newPasswordController.text;
        final renewPassword = _renewPasswordController.text;

        if (currentPassword.isEmpty ||
            newPassword.isEmpty ||
            renewPassword.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("빈칸 없이 모두 입력해주세요.")));
          return;
        }

        if (newPassword != renewPassword) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("새로운 비밀번호가 일치하지 않습니다.")));
          return;
        }

        final result = await AuthService.updatePassword(
          currentPassword,
          newPassword,
        );

        if (result == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result)));
        }
      },
      child: Container(
        width: 140,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            '완료',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
