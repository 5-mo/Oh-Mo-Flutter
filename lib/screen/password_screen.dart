import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PasswordScreen extends StatefulWidget {

  const PasswordScreen({Key? key}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
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
              color: Colors.white,
              fontFamily: 'PretendardBold',
              fontSize: 16,
            ),
          ),
        ),

        actions: <Widget>[
          TextButton(
            onPressed: () {
              print(_passwordController.text);
              Navigator.pop(context, {
                'password': _passwordController.text
              });
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
          Positioned(
            child: SvgPicture.asset(
              'android/assets/images/background_edit.svg',
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            top: 217,
            left: 38,
            child: Column(
              children: [
                _buildEditPassword(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          '비밀번호 재설정',

          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: 'PretendardBold',
          ),
        ),

        Container(
          width: 320,
          child: TextField(
            obscureText: true,
            controller: _passwordController,
            style: TextStyle(
              color: Colors.white,

              fontSize: 16.0,

              fontFamily: 'PretendardRegular',
            ),

            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),

              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),

              suffixIcon:
              _passwordController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey, size: 14),

                onPressed: () {
                  setState(() {
                    _passwordController.clear();
                  });
                },
              )
                  : null,
            ),

            onChanged: (value) {
              setState(() {});
            },
          ),
        ),

        SizedBox(height: 10.0),
      ],
    );
  }
}