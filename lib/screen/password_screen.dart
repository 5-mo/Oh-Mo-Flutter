import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/services/auth_service.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? _oldPasswordErrorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

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
              color: Colors.white,
              fontFamily: 'PretendardBold',
              fontSize: 16,
            ),
          ),
        ),

        actions: <Widget>[
          TextButton(
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      String oldPw = _oldPasswordController.text;
                      String newPw = _newPasswordController.text;

                      if (oldPw.isEmpty || newPw.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("모든 필드를 입력해주세요.")),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                        _oldPasswordErrorText = null;
                      });
                      final result = await AuthService.updatePassword(
                        oldPw,
                        newPw,
                      );

                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (result == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("비밀번호가 성공적으로 변경되었습니다."),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _oldPasswordErrorText = "비밀번호가 틀렸습니다. 다시 입력해주세요.";
                          });
                        }
                      }
                    },
            child: Text(
              '완료',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PretendardBold',
                fontSize: 16,
              ),
            ),
          ),
        ],

        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'android/assets/images/background_edit.svg',
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            top: 217,
            left: 38,
            right: 38,
            child: Column(
              children: [
                _buildPasswordField(
                  '현재 비밀번호',
                  _oldPasswordController,
                  _oldPasswordErrorText,
                ),
                const SizedBox(height: 30),
                _buildPasswordField('새 비밀번호', _newPasswordController, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: 'PretendardBold',
          ),
        ),
        TextField(
          obscureText: true,
          obscuringCharacter: '*',
          controller: controller,
          style: TextStyle(
            color: errorText != null ? const Color(0xFFDC2626) : Colors.white,
            fontSize: 16.0,
            fontFamily: 'PretendardRegular',
          ),

          decoration: InputDecoration(
            errorText: errorText,
            errorStyle: const TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 11,
              fontFamily: 'PretendardSemiBold',
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),

            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white,),
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
            if (errorText != null) {
              setState(() {
                if (label == '현재 비밀번호') _oldPasswordErrorText = null;
              });
            }
          },
        ),
      ],
    );
  }
}
