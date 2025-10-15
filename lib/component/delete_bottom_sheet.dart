import 'package:flutter/material.dart';

import 'delete_popup.dart';

class DeleteBottomSheet extends StatefulWidget {
  final VoidCallback onDelete;
  final bool showConfirmationPopup;

  const DeleteBottomSheet({
    Key? key,
    required this.onDelete,
    this.showConfirmationPopup = true,
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
              _builddeleteButton(context),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _builddeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.showConfirmationPopup) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (_) {
              return DeletePopup(
                messageHeader: '루틴 삭제',
                message: '이후 일정만 삭제되고, 이전 루틴 기록은\n유지됩니다. 삭제를 진행하시겠어요?',
                onDelete: widget.onDelete,
              );
            },
          );
        } else {
          widget.onDelete();
          Navigator.of(context).pop();
        }
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
