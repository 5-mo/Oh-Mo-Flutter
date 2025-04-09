import 'package:flutter/material.dart';

class DeletePopup extends StatefulWidget {
  final VoidCallback onDelete;

  const DeletePopup({Key? key, required this.onDelete}) : super(key: key);

  @override
  State<DeletePopup> createState() => _CategoryRoutineBottomSheetState();
}

class _CategoryRoutineBottomSheetState extends State<DeletePopup> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          '삭제', textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardBold', fontSize: 24.0),
        ),
        content: const Text(
          '해당 목록을 삭제할까요?', textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 15.0),
        ),
        actions: [_builddeleteButton()],
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
          color: Colors.red,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            '삭제하기',
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
