import 'package:flutter/material.dart';

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
      resizeToAvoidBottomInset: true,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
            ],
          ),
        ),
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
      onTap: () {
        print('회원가입 완료');
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
