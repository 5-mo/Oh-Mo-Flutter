import 'package:flutter/material.dart';
import 'package:ohmo/component/invitation_accept_popup.dart';

class InvitationPopup extends StatefulWidget {
  const InvitationPopup({Key? key}) : super(key: key);

  @override
  State<InvitationPopup> createState() => _InvitationPopupState();
}

class _InvitationPopupState extends State<InvitationPopup> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(37)),
        title: Text(
          '\n초대장이 도착했어요!\n새로운 그룹에 입장하세요',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 16.0),
        ),
        contentPadding: EdgeInsets.fromLTRB(32.0, 20, 32.0, 5.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'android/assets/images/invitation.png',
              width: 139,
              height: 130,
            ),
            SizedBox(height: 39),
            _buildCheckInvitationButton(),
            SizedBox(height: 10),
            _buildLaterButton(),
          ],
        ),
        actions: <Widget>[],
      ),
    );
  }

  Widget _buildCheckInvitationButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>InvitationAcceptPopup(),
          ),
        );
      },
      child: Container(
        width: 239,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            '초대장 확인하기',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLaterButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        width: 238,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
          ],
        ),
        child: Center(
          child: Text(
            '나중에',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'PretendardSemibold',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
