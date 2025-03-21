import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';

class TodoCard extends StatefulWidget {
  final String content;

  const TodoCard({required this.content, Key? key})
      : super(key: key);

  @override
  _TodoCardState createState()=>_TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontFamily: 'PretendardRegular',
      decoration: _isChecked ? TextDecoration.lineThrough:TextDecoration.none,
      color: _isChecked ? Middle_GREY_COLOR:Colors.black,
      decorationColor: _isChecked ? Middle_GREY_COLOR:Colors.black
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width:12,
              height:12,
              decoration:BoxDecoration(
                shape: BoxShape.circle,
                color:Colors.red,
              ),
            ),
            SizedBox(width:30.0),
            _Content(content: widget.content,textStyle: textStyle),
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
              activeColor: Colors.black,
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.all(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}


class _Content extends StatelessWidget {
  final String content;
  final TextStyle textStyle;

  const _Content({required this.content, required this.textStyle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(content,
        style:textStyle,
      ),
    );
  }
}
