import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';

class TodoBanner extends StatelessWidget {
  const TodoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);

    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('To-Do list', style: textStyle),
            IconButton(
              icon: SvgPicture.asset('android/assets/images/plus2.svg'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(59),
                      topLeft: Radius.circular(59),
                    ),
                  ),
                  builder: (_) => TodoBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
