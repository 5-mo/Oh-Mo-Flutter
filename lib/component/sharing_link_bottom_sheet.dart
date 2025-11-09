import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ohmo/db/drift_database.dart';

class SharingLinkBottomSheet extends StatefulWidget {
  final int groupId;

  const SharingLinkBottomSheet({Key? key, required this.groupId})
    : super(key: key);

  @override
  State<SharingLinkBottomSheet> createState() => _SharingLinkBottomSheetState();
}

class _SharingLinkBottomSheetState extends State<SharingLinkBottomSheet> {
  final db = LocalDatabaseSingleton.instance;

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
              _buildSharingLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharingLink() {
    return FutureBuilder<Group?>(
      future: db.getGroupById(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text(
            "그룹 정보를 불러오는 데 실패했습니다.",
            style: TextStyle(color: Colors.red),
          );
        }
        final group = snapshot.data!;
        final String groupName = group.name;
        final String inviteText = "SKDJFLJSLJDFLJS"; //초대 코드 연결 필요

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                await Share.share(inviteText);

                if (mounted) {
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
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3,
                    ),
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
      },
    );
  }
}
