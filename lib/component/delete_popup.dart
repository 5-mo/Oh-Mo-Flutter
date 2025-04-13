import 'package:flutter/material.dart';

class DeletePopup extends StatefulWidget {
  final VoidCallback onDelete;
  final String messageHeader;
  final String message;

  const DeletePopup({
    Key? key,
    required this.onDelete,
    required this.messageHeader,
    required this.message,
  }) : super(key: key);

  @override
  State<DeletePopup> createState() => _DeletePopupState();
}

class _DeletePopupState extends State<DeletePopup> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          widget.messageHeader, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardBold', fontSize: 24.0),
        ),
        content: Text(
          widget.message, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 15.0),
        ),
        actions: [_builddeleteButton()],
      ),
    );
  }

  Widget _builddeleteButton() {
    return GestureDetector(
      onTap: () {
        widget.onDelete();
        Navigator.of(context).pop();
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFE04747),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            '삭제하기',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
