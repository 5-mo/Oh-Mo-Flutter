import 'package:flutter/material.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';

import '../const/colors.dart';

import 'package:ohmo/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;

import '../db/drift_database.dart' as db;
import '../services/group_service.dart';

class InvitationAcceptPopup extends StatefulWidget {
  final int invitationId;
  final int groupId;
  final String groupName;
  final String? groupColor;

  const InvitationAcceptPopup({
    Key? key,
    required this.invitationId,
    required this.groupId,
    required this.groupName,
    this.groupColor,
  }) : super(key: key);

  @override
  State<InvitationAcceptPopup> createState() => _InvitationAcceptPopupState();
}

class _InvitationAcceptPopupState extends State<InvitationAcceptPopup> {
  bool _isLoading = true;
  String? _groupName;
  String? _groupColor;
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    _loadAllGroupInfo();
  }

  Future<void> _loadAllGroupInfo() async {
    try {
      final groupService = GroupService();
      final detail = await groupService.getGroupDetail(widget.groupId);
      final memberResult = await groupService.fetchGroupMembers(widget.groupId);

      print("서버 응답 상세: $detail");
      print("서버 응답 멤버: $memberResult");

      if (mounted) {
        setState(() {

          _groupName = detail?['groupName'] ?? widget.groupName;
          _groupColor = detail?['groupColor'];

          _members = memberResult?['memberList'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("에러 발생: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(37)),

      contentPadding: EdgeInsets.fromLTRB(32.0, 20, 32.0, 5.0),
      content:
          _isLoading
              ? Container(
                height: 200,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\n'${_groupName ?? widget.groupName}' 그룹이\n당신을 초대합니다!\n",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PretendardSemiBold',
                      fontSize: 16.0,
                    ),
                  ),
                  _buildCard(),
                  SizedBox(height: 39),
                  _buildCheckInvitationButton(),
                  SizedBox(height: 10),
                  _buildLaterButton(),
                ],
              ),
      actions: <Widget>[],
    );
  }

  Widget _buildCard() {
    final Color cardColor =
        (_groupColor != null)
            ? Color(int.parse(_groupColor!.replaceFirst('#', '0xFF')))
            : ColorManager.getColor(ColorType.pinkLight);
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
        color: cardColor,
      ),
      child: Column(
        children: [
          Text(
            _groupName ?? '',
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 12.0),
          ),
          SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ..._members
                    .take(3)
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: _buildMemberProfile(
                          'android/assets/images/clear_ohmo.png',
                          m['nickname'] ?? '멤버',
                        ),
                      ),
                    )
                    .toList(),
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
        final success = await GroupService().acceptInvitation(
          widget.invitationId,
        );
        if (success) {
          final localDb = db.LocalDatabaseSingleton.instance;

          await localDb.insertNotification(
            db.NotificationsCompanion(
              type: drift.Value('invitation'),
              content: drift.Value("'${widget.groupName}' 그룹에 입장했습니다."),
              timestamp: drift.Value(DateTime.now()),
              relatedId: drift.Value(widget.groupId),
              isRead: drift.Value(true),
            ),
          );
        }

        if (mounted) {
          Navigator.pop(context, true);
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
      onTap: () async {
        final success = await GroupService().rejectInvitation(
          widget.invitationId,
        );
        if (success && mounted) {
          Navigator.of(context).pop();
        }
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

  Widget _buildMemberProfile(String imagePath, String nickname) {
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
