import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:ohmo/db/drift_database.dart';
import 'dart:async';

class InvitingIdBottomSheet extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String title;

  const InvitingIdBottomSheet({
    Key? key,
    required this.groupId,
    required this.groupName,
    this.title = "아이디로 초대하기",
  }) : super(key: key);

  @override
  State<InvitingIdBottomSheet> createState() => _InvitingIdBottomSheetState();
}

class _InvitingIdBottomSheetState extends State<InvitingIdBottomSheet> {
  final db = LocalDatabaseSingleton.instance;
  final _idController = TextEditingController();

  bool _isIdValid = false;
  Timer? _debounce;

  late Future<Group?> _groupFuture;

  @override
  void initState() {
    super.initState();
    _groupFuture = db.getGroupById(widget.groupId);
    _idController.addListener(_onIdChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _idController.removeListener(_onIdChanged);
    _idController.dispose();
    super.dispose();
  }

  void _onIdChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final id = _idController.text.trim();
      if (id.isEmpty) {
        if (mounted) setState(() => _isIdValid = false);
        return;
      }
      final bool exists = (id == "test"); // db 연결 필요

      if (mounted) {
        setState(() {
          _isIdValid = exists;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 42,
          right: 42,
          top: 42,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
              ),
              SizedBox(height: 3),
              _buildIdSection(),
              SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdSection() {
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
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _idController,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'PretendardMedium',
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "아이디를 입력하세요",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: 'PretendardMedium',
                      color: Color(0xFFAFAFAF),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 2),
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'android/assets/images/round_check.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    _isIdValid ? Colors.black : Color(0xFFAFAFAF),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  if (_isIdValid) {
                    final enteredId = _idController.text.trim();
                    print('초대할 ID: $enteredId');

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    print('유효하지 않은 ID입니다.');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          final String id = _idController.text;

          if (id.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("아이디를 입력해주세요.")));
            return;
          }
          if (_isIdValid) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("존재하지 않는 아이디입니다.")));
          }
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
              '초대하기',
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
}
