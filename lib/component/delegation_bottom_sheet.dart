import 'package:flutter/material.dart';
import 'package:ohmo/db/drift_database.dart';

import 'group_popup.dart';

class DelegationBottomSheet extends StatefulWidget {
  final int groupId;
  final int currentUserId;

  const DelegationBottomSheet({
    Key? key,
    required this.groupId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<DelegationBottomSheet> createState() =>
      _DelegationBottomSheetState();
}

class _DelegationBottomSheetState
    extends State<DelegationBottomSheet> {
  late final LocalDatabase _db;
  List<MemberInfo> _members = [];
  MemberInfo? _selectedMember;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    /*
    try {
      final allMembers = await _db.getMembersForGroup(widget.groupId);

      final kickableMembers =
          allMembers.where((m) => m.role != 'OWNER').toList();

      if (mounted) {
        setState(() {
          _members = kickableMembers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      print('멤버 로딩 실패:$e');
    }
     */
    if (mounted) {
      setState(() {
        _members = [
          MemberInfo(userId: 101, nickname: '이유진', role: 'MEMBER'),
          MemberInfo(userId: 102, nickname: '홍재원', role: 'MEMBER'),
          MemberInfo(userId: 103, nickname: '정은지', role: 'MEMBER'),
          MemberInfo(userId: 104, nickname: '임효진', role: 'MEMBER'),
        ];
      });
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
              '방장 권한 넘기기',
              style: TextStyle(fontFamily: 'PretendardBold', fontSize: 16.0),
            ),
            _buildMemberList(),
            _buildDelegateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberList() {
    if (_members.isEmpty) {
      return Center(child: Text('권한을 넘길 멤버가 없습니다.'));
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
    final bool isSelected =
    (_selectedMember != null && _selectedMember!.userId == member.userId);
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
                backgroundImage: AssetImage(
                  'android/assets/images/clear_ohmo.png',
                ),
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

  Widget _buildDelegateButton() {
    final bool isButtonActive = _selectedMember != null;
    return Center(
      child: GestureDetector(
        onTap: () {
          if (isButtonActive) {
            _confirmDelegate(_selectedMember!);
          }
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2.8),
            ],
          ),
          child: Center(
            child: Text(
              '이 멤버에게 권한 넘기기',
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

  Future<void> _confirmDelegate(MemberInfo member) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GroupPopup(
          messageHeader: '방장 권한 넘기기',
          message: "해당 멤버에게 방장 권한이 이전됩니다.\n진행하시겠습니까?",
          confirmButtonText: '권한 넘기기',
        );
      },
    );

    if (confirmed == true) {
      try {
        await _db.delegateOwnership(widget.groupId, member.userId,widget.currentUserId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${member.nickname}'님을 권한을 넘겼습니다.")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('권한 넘기기 실패: $e')));
      }
    }
  }
}
