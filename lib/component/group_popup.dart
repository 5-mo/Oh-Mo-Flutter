import 'package:flutter/material.dart';

class GroupPopup extends StatelessWidget {
  final String messageHeader;
  final String message;
  final String confirmButtonText;
  final Color? confirmButtonColor;
  final bool showCancelButton;

  const GroupPopup({
    Key? key,
    required this.messageHeader,
    required this.message,
    this.confirmButtonText = '확인',
    this.confirmButtonColor,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          messageHeader,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardBold', fontSize: 20.0),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 16.0),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        actions: [
          Column(
            children: [
              _buildConfirmButton(context),
              const SizedBox(height: 8),
              if (showCancelButton) ...[
                _buildCancelButton(context),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(true);
      },
      child: Container(
        width: 277,
        height: 54,
        decoration: BoxDecoration(
          color: confirmButtonColor ?? Colors.black,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2.8),
          ],
        ),
        child: Center(
          child: Text(
            confirmButtonText,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(false);
      },
      child: Container(
        width: 277,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardBold',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
