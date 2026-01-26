import 'package:flutter/material.dart';
import 'package:ohmo/component/group_popup.dart';
import 'package:ohmo/component/sharing_link_bottom_sheet.dart';
import '../../component/inviting_id_bottom_sheet.dart';
import '../../const/colors.dart';
import '../../services/group_service.dart';
import '../category_screen.dart';

class GroupAddMemberScreen extends StatefulWidget {
  final String roomName;
  final ColorType selectedColor;
  final int memberCount;
  final String password;

  const GroupAddMemberScreen({
    Key? key,
    required this.roomName,
    required this.selectedColor,
    required this.memberCount,
    required this.password,
  }) : super(key: key);

  @override
  _GroupAddMemberScreenState createState() => _GroupAddMemberScreenState();
}

class _GroupAddMemberScreenState extends State<GroupAddMemberScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60.0),
            _buildSharingHeader(),
            SizedBox(height: 50.0),
            _buildNickname(),
            SizedBox(height: 10.0),
            _buildNicknameTextField(_nicknameController),
            SizedBox(height: 55.0),
            _buildSharingButton(),
            SizedBox(height: 8.0),
            _buildInvitingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'Let\'s Go!',
            style: TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Text(
            '새로운 그룹을 만들었어요!\n함께하고 싶은 멤버들을 초대해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardSemiBold', fontSize: 14.0),
          ),
          SizedBox(height: 40),
          Image.asset('android/assets/images/ohmo_letsgo.png', width: 200),
        ],
      ),
    );
  }

  Widget _buildNickname() {
    return Center(
      child: Column(
        children: [
          Text(
            '닉네임을 설정하세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'PretendardMedium', fontSize: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameTextField(TextEditingController controller) {
    return Container(
      width: 168,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,

          prefixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.transparent,
                      size: 14,
                    ),
                    onPressed: null,
                  )
                  : null,

          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.cancel, color: ICON_GREY_COLOR, size: 14),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  )
                  : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildSharingButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _createGroupAndShowSheet(isSharingLink: true);
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '공유 링크 보내기',
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

  Widget _buildInvitingButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _createGroupAndShowSheet(isSharingLink: false);
        },
        child: Container(
          width: 327,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              '아이디로 초대하기',
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

  Future<void> _createGroupAndShowSheet({required bool isSharingLink}) async {
    final String nickname = _nicknameController.text;

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요.')));
      return;
    }

    try {
      final Map<String,dynamic> groupResult = await _groupService.createGroup(
        groupName: widget.roomName,
        password: widget.password,
        groupColor: widget.selectedColor.name,
        memberCount: widget.memberCount,
        nickname: nickname,
      );

      final int serverGroupId=groupResult['groupId'];
      final String serverGroupCode=groupResult['groupCode'];

      if (!mounted) return;

      final bool? result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        builder:
            (_) =>
                isSharingLink
                    ? SharingLinkBottomSheet(
                      groupName: widget.roomName,
                      groupCode: serverGroupCode,
                    )
                    : InvitingIdBottomSheet(groupId: serverGroupId,groupName: widget.roomName,),
      );

      if (result == true && mounted) {
        await Future.delayed(const Duration(milliseconds: 200));

        final bool? isConfirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => const GroupPopup(
                messageHeader: "멤버 초대하기",
                message: "성공적으로 초대장이 발송되었습니다!",
                confirmButtonText: "확인",
                showCancelButton: false,
              ),
        );
        if (isConfirmed == true && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CategoryScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '그룹 생성에 실패했습니다: ${e.toString().replaceAll('Exception:', '')}',
          ),
        ),
      );
    }
  }
}
