import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SharingLinkBottomSheet extends StatefulWidget {
  const SharingLinkBottomSheet({Key? key}) : super(key: key);

  @override
  State<SharingLinkBottomSheet> createState() => _SharingLinkBottomSheetState();
}

class _SharingLinkBottomSheetState extends State<SharingLinkBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 49,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 9),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 15),
              Text(
                "'사이드 프로젝트' 그룹에 입장하세요!",
                style: TextStyle(fontSize: 15, fontFamily: 'PretendardMedium'),
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
      ],
    );
  }
}
