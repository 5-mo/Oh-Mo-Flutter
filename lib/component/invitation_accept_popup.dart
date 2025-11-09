import 'package:flutter/material.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';

import '../const/colors.dart';

import 'package:ohmo/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;

import '../db/drift_database.dart' as db;

class InvitationAcceptPopup extends StatefulWidget {
  const InvitationAcceptPopup({Key? key}) : super(key: key);

  @override
  State<InvitationAcceptPopup> createState() => _InvitationAcceptPopupState();
}

class _InvitationAcceptPopupState extends State<InvitationAcceptPopup> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(37)),
        title: Text(
          "\n'사이드 프로젝트' 그룹이\n당신을 초대합니다!\n",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 16.0),
        ),

        contentPadding: EdgeInsets.fromLTRB(32.0, 20, 32.0, 5.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCard(),
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

  Widget _buildCard() {
    return Container(
      width: 206,
      height: 112,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 4.4,
            offset: Offset(2, 3),
          ),
        ],
        color: ColorManager.getColor(ColorType.pinkLight),
      ),
      child: Column(
        children: [
          Text(
            '사이드 프로젝트',
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 12.0),
          ),
          SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildMemberProfile('android/assets/images/clear_ohmo.png'),
                const SizedBox(width: 6),
                _buildMemberProfile('android/assets/images/clear_ohmo.png'),
                const SizedBox(width: 6),
                _buildMemberProfile('android/assets/images/clear_ohmo.png'),
                const SizedBox(width: 6),
                Transform.translate(
                  offset: Offset(0, -10.0),
                  child: Image.asset(
                    'android/assets/images/invitation_foryou.png',
                    width: 44,
                    height: 41,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInvitationButton() {
    return GestureDetector(
      onTap: () async {
        const String groupName = '사이드 프로젝트';
        const int groupId = 1;
        try {
          final localDb = db.LocalDatabaseSingleton.instance;

          await localDb.insertNotification(
            db.NotificationsCompanion(
              type: drift.Value('invitation'),
              content: drift.Value("'$groupName' 그룹에 입장했습니다."),
              timestamp: drift.Value(DateTime.now()),
              relatedId: drift.Value(groupId),
              isRead: drift.Value(true),
            ),
          );
        } catch (e) {
          print('Failed to insert "group joined" notification: $e');
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (cosntext) => GroupMainScreen(groupId: 1),
            ),
          );
        }
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
            '그룹 초대 수락하기',
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
            '거절하기',
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

  Widget _buildMemberProfile(String imagePath) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Column(
        children: [
          CircleAvatar(radius: 16, backgroundImage: AssetImage(imagePath)),
          Text(
            '오모',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'PretendardRegular',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
