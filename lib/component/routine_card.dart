import 'package:flutter/material.dart';

class RoutineCard extends StatefulWidget {
  final String content;

  const RoutineCard({required this.content, Key? key})
    : super(key: key);

  @override
  _RoutineCardState createState()=>_RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16.0);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
