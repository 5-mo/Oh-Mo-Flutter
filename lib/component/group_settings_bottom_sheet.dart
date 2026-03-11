import 'package:flutter/material.dart';
import 'package:ohmo/component/group_popup.dart';
import 'package:ohmo/component/managing_members_bottom_sheet.dart';
import 'package:ohmo/services/group_service.dart';

import '../const/colors.dart';
import 'color_palette_bottom_sheet.dart';
import 'delegation_bottom_sheet.dart';
import 'group_change_password_bottom_sheet.dart';
import 'inviting_id_bottom_sheet.dart';
import 'package:ohmo/db/drift_database.dart';

class GroupSettingsBottomSheet extends StatefulWidget {
  final int groupId;
  final String groupName;
  final Function(ColorType) onColorChanged;
  final String? initialRole;

  const GroupSettingsBottomSheet({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.onColorChanged,
    this.initialRole,
  }) : super(key: key);

  @override
  State<GroupSettingsBottomSheet> createState() =>
      _GroupSettingsBottomSheetState();
}

class _GroupSettingsBottomSheetState extends State<GroupSettingsBottomSheet> {
  static const int currentUserId = 1; //db 반영
  ColorType _selectedColorType = ColorType.pinkLight;

  late final LocalDatabase _db;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;

    if (widget.initialRole != null) {
      _userRole = widget.initialRole;
    } else {
      _fetchUserRole();
    }
  }

  Future<void> _fetchUserRole() async {
    try {
      final groupData = await GroupService().fetchGroupMembers(widget.groupId);

      if (groupData != null) {
        final myEmail = await GroupService().getMyEmail();

        final List members = groupData['memberGroupInfos'] ?? [];
        final myInfo = members.firstWhere(
          (m) => m['memberInfo']['email'] == myEmail,
          orElse: () => null,
        );

        if (mounted && myInfo != null) {
          setState(() {
            _userRole = myInfo['role'];
          });
          return;
        }
      }
    } catch (e) {
      print("권한 조회 실패 : $e");
    }
    final role = await _db.getMemberRole(widget.groupId, currentUserId);

    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userRole == 'OWNER' || _userRole == 'MANAGER';
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              _buildChangingColor(),
              SizedBox(height: 10),
              _buildInvitingMember(),
              SizedBox(height: 10),

              if (isAdmin) ...[
                _buildManageMembersButton(),
                SizedBox(height: 10),
                _buildDelegationButton(),
                SizedBox(height: 10),
                _buildPasswordButton(),
              ],
              SizedBox(height: 20),
              if (isAdmin)
                _buildDeleteGroupButton()
              else
                _buildLeaveGroupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangingColor() {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<ColorType>(
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
          builder:
              (paletteContext) => ColorPaletteBottomSheet(
                selectedColorType: _selectedColorType,
                onColorSelected: (colorType) async {
                  try {
                    await _db.updateLocalColor(widget.groupId, colorType, widget.groupName);

                    final check = await _db.getGroupById(widget.groupId);

                    widget.onColorChanged(colorType);
                    if (mounted) {
                      Navigator.of(paletteContext).pop();
                    }
                  } catch (e) {
                    print("로컬 색상 저장 에러: $e");
                  }
                },
              ),
        );
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '색깔 변경하기',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardMedium',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitingMember() {
    return GestureDetector(
      onTap: () async {
        final bool? result = await showModalBottomSheet<bool>(
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
          builder: (context) {
            return InvitingIdBottomSheet(
              groupId: widget.groupId,
              groupName: widget.groupName,
            );
          },
        );
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '멤버 초대하기                                            >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardMedium',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageMembersButton() {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);

        final bool? kicked = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(59),
              topRight: Radius.circular(59),
            ),
          ),
          builder:
              (_) => ManagingMembersBottomSheet(
                groupId: widget.groupId,
                currentUserId: currentUserId, //db 반영
              ),
        );

        if (kicked == true) {}
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '멤버 내보내기                                            >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardMedium',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDelegationButton() {
    return GestureDetector(
      onTap: () async {
        final bool? delegated = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(59),
              topRight: Radius.circular(59),
            ),
          ),
          builder:
              (_) => DelegationBottomSheet(
                groupId: widget.groupId,
                currentUserId: currentUserId,
              ),
        );

        if (delegated == true) {
          _fetchUserRole();
        }
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '방장 권한 넘기기                                        >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardMedium',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(59),
              topRight: Radius.circular(59),
            ),
          ),
          builder:
              (_) => GroupChangePasswordBottomSheet(groupId: widget.groupId),
        );
      },
      child: Container(
        width: 318,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              '잠금 설정하기                                            >',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'PretendardMedium',
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveGroupButton() {
    return GestureDetector(
      onTap: () => _handleLeaveGroup(context),
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Text(
          textAlign: TextAlign.center,
          '나가기',
          style: TextStyle(
            fontFamily: 'PretendardBold',
            fontSize: 16,
            color: Color(0xFFC41E1E),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteGroupButton() {
    return GestureDetector(
      onTap: () => _handleDeleteGroup(context),
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Text(
          textAlign: TextAlign.center,
          '그룹 삭제하기',
          style: TextStyle(
            fontFamily: 'PretendardBold',
            fontSize: 16,
            color: Color(0xFFC41E1E),
          ),
        ),
      ),
    );
  }

  void _handleLeaveGroup(BuildContext pageContext) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GroupPopup(
          messageHeader: '나가기',
          message: '해당 그룹을 정말 나가시겠습니까?',
          confirmButtonText: '나가기',
          confirmButtonColor: Color(0xFFC41E1E),
        );
      },
    );
    if (confirmed == true) {
      try {
        await _db.leaveGroup(widget.groupId, currentUserId);

        if (mounted) {
          Navigator.of(pageContext).pop('leave');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('그룹 나가기에 실패했습니다 : $e')));
        }
      }
    }
  }

  void _handleDeleteGroup(BuildContext pageContext) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GroupPopup(
          messageHeader: '그룹 삭제하기',
          message: '그룹의 모든 일정이 사라지고\n복구되지 않습니다.\n해당 그룹을 정말 삭제하시겠습니까?',
          confirmButtonText: '그룹 삭제하기',
          confirmButtonColor: Color(0xFFC41E1E),
        );
      },
    );
    if (confirmed == true) {
      try {
        await GroupService().deleteGroup(
          groupId: widget.groupId,
          groupPassword: "",
        );

        await _db.deleteGroup(widget.groupId);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('그룹이 삭제되었습니다.')));
          Navigator.of(pageContext).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('그룹 삭제에 실패했습니다 :$e')));
        }
      }
    }
  }
}
