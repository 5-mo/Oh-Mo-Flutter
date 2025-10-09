import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/routine_bottom_sheet.dart';

class RoutineBanner extends StatelessWidget {
  final VoidCallback onAddPressed;
  final int? groupId;

  const RoutineBanner({Key? key, required this.onAddPressed, this.groupId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);

    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Routine', style: textStyle),
            Transform.translate(
              offset: Offset(5, 0),
              child: IconButton(
                icon: SvgPicture.asset('android/assets/images/plus.svg'),
                onPressed: onAddPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
