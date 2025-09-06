import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';
import 'package:flutter_svg/svg.dart';
import '../db/drift_database.dart';
import 'alarm_bottom_sheet.dart';
import 'color_palette_bottom_sheet.dart';
import 'delete_popup.dart';

class TodoCard extends StatefulWidget {
  final String content;
  final Function(String) onEdit;
  final bool showCheckbox;
  final Widget Function(BuildContext context)? deletePopupBuilder;
  final ColorType colorType;
  final int scheduleId;
  final bool isDone;
  final Future<void> Function()? onStatusChanged;

  const TodoCard({
    required this.content,
    required this.onEdit,
    required this.colorType,
    this.showCheckbox = true,
    this.deletePopupBuilder,
    required this.scheduleId,
    required this.isDone,
    this.onStatusChanged,
    Key? key,
  }) : super(key: key);

  @override
  _TodoCardState createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  late bool _isChecked;
  bool _isEditing = false;
  late TextEditingController _controller;
  ColorType _selectedColorType = ColorType.pinkLight;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isDone;
    _controller = TextEditingController(text: widget.content);
    _selectedColorType = widget.colorType;
  }

  @override
  void didUpdateWidget(covariant TodoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.content != widget.content) {
      _controller.text = widget.content;
    }

    if (oldWidget.isDone != widget.isDone) {
      _isChecked = widget.isDone;
    }

    if (oldWidget.colorType != widget.colorType) {
      _selectedColorType = widget.colorType;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontFamily: 'PretendardRegular',
      decoration: _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
      color: _isChecked ? Middle_GREY_COLOR : Colors.black,
      decorationColor: _isChecked ? Middle_GREY_COLOR : Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _openColorPicker(context),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.getColor(_selectedColorType),
                ),
              ),
            ),
            const SizedBox(width: 30.0),
            Expanded(
              child: _isEditing
                  ? TextField(
                controller: _controller,
                style: textStyle,
                autofocus: true,
                onSubmitted: (value) async {
                  setState(() => _isEditing = false);
                  widget.onEdit(value);

                  final db = LocalDatabase();
                  await db.updateTodo(
                    TodosCompanion(
                      id: Value(widget.scheduleId),
                      content: Value(value),
                      colorType: Value(_selectedColorType.index),
                    ),
                  );
                },
                onTapOutside: (_) {
                  setState(() => _isEditing = false);
                  widget.onEdit(_controller.text);
                },
              )
                  : GestureDetector(
                onTap: () => setState(() => _isEditing = true),
                child: Text(_controller.text, style: textStyle),
              ),
            ),
            GestureDetector(
              onTap: () {
                final popupWidget = widget.deletePopupBuilder?.call(context);
                if (popupWidget is DeletePopup) {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.4),
                    builder: (_) => popupWidget,
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(59),
                        topLeft: Radius.circular(59),
                      ),
                    ),
                    builder:
                    widget.deletePopupBuilder ?? (context) => TodoAlarm(),
                  );
                }
              },
              child: SvgPicture.asset('android/assets/images/todo_alarm.svg'),
            ),
            const SizedBox(width: 8.0),
            widget.showCheckbox
                ? Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              value: _isChecked,
              onChanged: (bool? value) async {
                setState(() => _isChecked = value ?? false);

                try {
                  final db = LocalDatabase();
                  await db.toggleTodoStatus(widget.scheduleId);

                  if (widget.onStatusChanged != null) {
                    await widget.onStatusChanged!();
                  }
                } catch (e) {
                  print('투두 상태 변경 실패: $e');
                  setState(() => _isChecked = !(_isChecked));
                }
              },
              activeColor: Colors.black,
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.all(Colors.black),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _openColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(59),
          topLeft: Radius.circular(59),
        ),
      ),
      builder: (context) => ColorPaletteBottomSheet(
        selectedColorType: _selectedColorType,
        onColorSelected: (colorType) async {
          setState(() => _selectedColorType = colorType);

          final db = LocalDatabase();
          await db.updateTodo(
            TodosCompanion(
              id: Value(widget.scheduleId),
              colorType: Value(colorType.index),
            ),
          );
        },
      ),
    );
  }
}
