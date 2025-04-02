import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: SvgPicture.asset(
              'android/assets/images/mybackground.svg',
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            top: 66,
            left: 41,
            child: Row(
              children: [
                SvgPicture.asset('android/assets/images/myprofile.svg'),
                SizedBox(width: 50),
                _buildProfileSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final textStyle = TextStyle(
      fontFamily: 'PretendardRegular',
      fontSize: 16.0,
      color: Colors.white,
    );
    return Column(
      children: [
        Text('오모', style: textStyle),
        Text('jwjwhvv@gamil.com', style: textStyle),
        SizedBox(height: 10.0),
      ],
    );
  }


}
