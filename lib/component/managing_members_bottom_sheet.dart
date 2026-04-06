import 'package:flutter/material.dart';
import 'package:ohmo/db/drift_database.dart';

import '../services/group_service.dart';
import 'group_popup.dart';

class ManagingMembersBottomSheet extends StatefulWidget {
  final int groupId;
  final int currentUserId;

  const ManagingMembersBottomSheet({
    Key? key,
    required this.groupId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ManagingMembersBottomSheet> createState() =>
      _ManagingMembersBottomSheetState();
}

class _ManagingMembersBottomSheetState
    extends State<ManagingMembersBottomSheet> {
  late final LocalDatabase _db;
  List<MemberInfo> _members = [];
  MemberInfo? _selectedMember;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final groupService = GroupService();
      final data = await groupService.fetchGroupMembers(widget.groupId);

      if (data != null) {
        final List<dynamic> memberList =
            data['memberGroupInfos'] ?? data['memberDtoList'] ?? [];

        final myEmail = await groupService.getMyEmail();

        final List<MemberInfo> fetchMembers =
            memberList.where((m) => m['memberInfo']['email'] != myEmail).map((
              m,
            ) {
              final Map<String, dynamic> info = m['memberInfo'] ?? {};

              final String? groupNickname = m['nickname']?.toString();
              final String? globalNickname = info['nickname']?.toString();
              final String finalNickname =
                  groupNickname ?? globalNickname ?? '이름 없음';
              return MemberInfo(
                userId: m['memberInfo']?['userId'] ?? 0,
                memberGroupId: m['memberGroupId'],
                nickname: finalNickname,
                role: m['role'] ?? 'MEMBER',
                profileImageUrl:
                    info['profileImageUrl'] ?? info['profileImage'],
              );
            }).toList();

        if (mounted) {
          setState(() {
            _members = fetchMembers;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('멤버 로딩 실패 : $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('멤버 목록을 불러오지 못했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: 40, left: 42, right: 42, top: 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '멤버 내보내기',
              style: TextStyle(fontFamily: 'PretendardBold', fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            _buildMemberList(),
            _buildKickButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberList() {
    if (_members.isEmpty) {
      return Center(child: Text('\n내보낼 수 있는 멤버가 없습니다.\n\n'));
    }
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return _buildMemberItem(member);
        },
      ),
    );
  }

  Widget _buildMemberItem(MemberInfo member) {
    final bool isSelected = (_selectedMember != null &&
        _selectedMember!.memberGroupId == member.memberGroupId);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMember = null;
          } else {
            _selectedMember = member;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 3.0,
                ),
              ),
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (() {
                          final path = member.profileImageUrl;
                          if (path == null || path.isEmpty) {
                            return const AssetImage(
                              'android/assets/images/clear_ohmo.png',
                            );
                          }
                          if (path.startsWith('http')) {
                            return NetworkImage(path);
                          }
                          return AssetImage(path);
                        })()
                        as ImageProvider?,
                child:
                    (member.profileImageUrl == null ||
                            member.profileImageUrl!.isEmpty)
                        ? ClipOval(
                          child: Image.asset(
                            'android/assets/images/clear_ohmo.png',
                            fit: BoxFit.cover,
                          ),
                        )
                        : null,
              ),
            ),
            SizedBox(height: 5),
            Text(
              member.nickname,
              style: TextStyle(
                fontFamily: isSelected ? 'PretendardBold' : 'PretendardRegular',
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKickButton() {
    final bool isButtonActive = _selectedMember != null;
    return Center(
      child: GestureDetector(
        onTap: () {
          if (isButtonActive) {
            _confirmKick(_selectedMember!);
          }
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Color(0xFFE04747),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2.8),
            ],
          ),
          child: Center(
            child: Text(
              '내보내기',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PretendardBold',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmKick(MemberInfo member) async {
    if (member.memberGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('멤버 정보가 올바르지 않습니다.')));
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GroupPopup(
          messageHeader: '멤버 내보내기',
          message: "선택한 멤버를 정말 내보내시겠어요?",
          confirmButtonText: '내보내기',
          confirmButtonColor: Color(0xFFE04747),
        );
      },
    );

    if (confirmed == true) {
      try {
        final groupService = GroupService();

        final bool isSuccess = await groupService.kickGroupMember(
          groupId: widget.groupId,
          targetMemberGroupId: member.memberGroupId!,
        );

        if (isSuccess) {
          await _db.removeMemberFromGroup(widget.groupId, member.userId);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("'${member.nickname}'님을 내보냈습니다.")),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('서버에서 강퇴 처리에 실패했습니다.');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('내보내기 실패: $e')));
      }
    }
  }
}
