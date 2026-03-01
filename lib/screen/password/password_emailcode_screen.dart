import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/services/auth_service.dart';

class PasswordEmailCodeScreen extends StatefulWidget {
  final String email;

  const PasswordEmailCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _PasswordEmailCodeScreenState createState() => _PasswordEmailCodeScreenState();
}

class _PasswordEmailCodeScreenState extends State<PasswordEmailCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _codeErrorText;
  String? _confirmErrorText;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    String code = _codeController.text.trim();
    String newPw = _newPasswordController.text.trim();
    String confirmPw = _confirmPasswordController.text.trim();

    if (code.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력해주세요.")),
      );
      return;
    }

    if (newPw != confirmPw) {
      setState(() {
        _confirmErrorText = "비밀번호가 일치하지 않습니다.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _codeErrorText = null;
      _confirmErrorText = null;
    });

    final errorResult = await AuthService.resetPassword(
      widget.email,
      code,
      newPw,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (errorResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() {
          _codeErrorText = errorResult;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(color: Colors.black, fontFamily: 'PretendardBold', fontSize: 16),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 38.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      '비밀번호 재설정',
                      style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 24.0, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 60),

                  _buildLabelText('이메일로 받은 인증코드를 입력해주세요'),
                  const SizedBox(height: 10),
                  _buildInputField(_codeController, _codeErrorText),

                  const SizedBox(height: 20),

                  _buildLabelText('새로운 비밀번호'),
                  const SizedBox(height: 10),
                  _buildInputField(_newPasswordController, null, isPassword: true),

                  const SizedBox(height: 20),

                  _buildLabelText('새로운 비밀번호를 다시 입력하세요'),
                  const SizedBox(height: 10),
                  _buildInputField(_confirmPasswordController, _confirmErrorText, isPassword: true),

                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 300),
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

  Widget _buildLabelText(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'PretendardBold', fontSize: 16, color: Color(0xFF575757)),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String? errorText, {
        bool isPassword = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      obscuringCharacter: '*',
      keyboardType: isPassword ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        errorText: errorText,
        errorStyle: const TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontFamily: 'PretendardSemiBold'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: Colors.grey)),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'android/assets/images/round_check.svg',
            height: 17,
            width: 17,
            colorFilter: ColorFilter.mode(
              controller.text.isNotEmpty ? Colors.black : const Color(0xFFAFAFAF),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleReset,
      child: Container(
        width: 140,
        height: 42,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(7)),
        child: Center(
          child: Text(
            _isLoading ? '처리중' : '완료',
            style: const TextStyle(fontSize: 16, fontFamily: 'PretendardBold', color: Colors.white),
          ),
        ),
      ),
    );
  }
}