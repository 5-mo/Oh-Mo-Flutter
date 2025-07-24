import 'package:flutter/material.dart';
import 'package:ohmo/models/profile_data_provider.dart';
import 'package:ohmo/services/auth_service.dart';
import 'package:ohmo/screen/home_screen.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          decoration: BoxDecoration(
            color: Colors.white,
          ),
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
                      '회원가입',
                      style: TextStyle(
                        fontFamily: 'PretendardSemibold',
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  _buildSignupText('닉네임'),
                  SizedBox(height: 10),
                  _buildTextField(_nicknameController),
                  SizedBox(height: 20),
                  _buildSignupText('이메일'),
                  SizedBox(height: 10),
                  _buildTextField(_emailController),
                  SizedBox(height: 20),
                  _buildSignupText('비밀번호'),
                  SizedBox(height: 10),
                  _buildTextField(_passwordController, isPassword: true),
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
          style: TextStyle(fontFamily: 'PretendardBold', fontSize: 16),
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
        final nickname = _nicknameController.text;
        final email = _emailController.text;
        final password = _passwordController.text;

        if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("빈칸 없이 모두 입력해주세요.")));
          return;
        }

        final result = await AuthService.signup(email, password, nickname);

        if (result == null) {
          print("회원가입 성공");

          final profile = Provider.of<ProfileData>(context, listen: false);
          profile.updateProfile(updateNickname: nickname, updateEmail: email);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
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
