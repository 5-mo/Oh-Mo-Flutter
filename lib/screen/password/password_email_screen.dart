import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/services/auth_service.dart';
import 'package:ohmo/screen/password/password_emailcode_screen.dart';

class PasswordEmailScreen extends StatefulWidget {
  const PasswordEmailScreen({Key? key}) : super(key: key);

  @override
  _PasswordEmailScreenState createState() => _PasswordEmailScreenState();
}

class _PasswordEmailScreenState extends State<PasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _checkEmailFormat(String email) {
    bool valid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);

    setState(() {
      _isEmailValid = valid;
    });
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일을 입력해주세요.")),
      );
      return;
    }

    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 이메일 형식을 입력해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.sendResetCode(email);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("인증 코드가 발송되었습니다.")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordEmailCodeScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
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
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const Center(
                  child: Text(
                    '비밀번호 재설정',
                    style: TextStyle(
                      fontFamily: 'PretendardMedium',
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                _buildLabelText('비밀번호를 재설정할 이메일을 입력해주세요'),
                const SizedBox(height: 10),

                _buildEmailField(),

                const SizedBox(height: 250),

                _buildSubmitButton(),
              ],
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

  Widget _buildLabelText(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'PretendardBold',
            fontSize: 16,
            color: Color(0xFF575757),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      width: 340,
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'android/assets/images/round_check.svg',
              height: 17,
              width: 17,
              colorFilter: ColorFilter.mode(
                _isEmailValid ? Colors.black : const Color(0xFFAFAFAF),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        onChanged: (value) {
          _checkEmailFormat(value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSendCode,
      child: Container(
        width: 140,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            _isLoading ? '전송중' : '완료',
            style: const TextStyle(
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