import 'package:flutter/material.dart';

class DeleteBottomSheet extends StatefulWidget {
  final VoidCallback onDelete;

  const DeleteBottomSheet({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DeleteBottomSheet> createState() => _DeleteBottomSheetState();
}

class _DeleteBottomSheetState extends State<DeleteBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              _builddeleteButton(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _builddeleteButton() {
    return GestureDetector(
      onTap: () {
        widget.onDelete();
        Navigator.of(context).pop();
      },
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFE04747),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            '일정 삭제하기',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PretendardBold',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}