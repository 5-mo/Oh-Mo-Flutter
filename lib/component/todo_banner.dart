import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';

class TodoBanner extends StatelessWidget {
  final VoidCallback onAddPressed;
  final int? groupId;

  const TodoBanner({Key? key, required this.onAddPressed,this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('To-Do list', style: textStyle),
          Transform.translate(
            offset: Offset(5, 0),
            child: IconButton(
              icon: SvgPicture.asset('android/assets/images/plus2.svg'),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}
