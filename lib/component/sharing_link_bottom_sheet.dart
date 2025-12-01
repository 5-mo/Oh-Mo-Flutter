import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class SharingLinkBottomSheet extends StatelessWidget {
  final String groupName;
  final String groupCode;

  const SharingLinkBottomSheet({
    Key? key,
    required this.groupName,
    required this.groupCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(42.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "공유 링크",
                style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
              ),
              SizedBox(height: 3),
              _buildSharingLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharingLink(BuildContext context) {
    final String inviteText =
        "오모(ohmo) 그룹 초대장\n\n그룹명:$groupName\n초대코드 : $groupCode\n\n앱에서 코드를 입력해 입장하세요!";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            await Share.share(inviteText);

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: double.infinity,
            height: 49,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: 15),
                Text(
                  "'$groupName' 그룹에 입장하세요!",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'PretendardMedium',
                  ),
                ),
                Spacer(),
                SvgPicture.asset(
                  'android/assets/images/copy.svg',
                  height: 20,
                  width: 20,
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
