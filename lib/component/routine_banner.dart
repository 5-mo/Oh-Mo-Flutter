import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RoutineBanner extends StatelessWidget {
  const RoutineBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 14.0);

    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Routine', style: textStyle),
            IconButton(
              icon: SvgPicture.asset('android/assets/images/plus.svg'),
              onPressed: () => print('plus'),
            ),
          ],
        ),
      ),
    );
  }
}