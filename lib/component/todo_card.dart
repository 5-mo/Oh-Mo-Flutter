import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ohmo/const/colors.dart';
import 'package:flutter_svg/svg.dart';
import '../db/drift_database.dart';
import 'alarm_bottom_sheet.dart';
import 'color_palette_bottom_sheet.dart';
import 'package:ohmo/services/notification_service.dart';

class TodoCard extends StatefulWidget {
  final String content;
  final bool showCheckbox;
  final Widget Function(BuildContext context)? deletePopupBuilder;
  final ColorType colorType;
  final int scheduleId;
  final bool isDone;
  final Future<void> Function()? onStatusChanged;
  final Function(int id, DateTime newDate)? onDateChanged;
  final VoidCallback? onDataChanged;
  final bool isColorPickerEnabled;
  final VoidCallback? onEditPressed;
  final VoidCallback? onAlarmPressed;

  const TodoCard({
    required this.content,
    required this.colorType,
    this.showCheckbox = true,
    this.deletePopupBuilder,
    required this.scheduleId,
    required this.isDone,
    this.onStatusChanged,
    this.onDateChanged,
    this.onDataChanged,
    this.isColorPickerEnabled = true,
    this.onEditPressed,
    this.onAlarmPressed,
    Key? key,
  }) : super(key: key);

  @override
  _TodoCardState createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  ColorType _selectedColorType = ColorType.pinkLight;

  @override
  void initState() {
    super.initState();
    _selectedColorType = widget.colorType;
  }

  @override
  void didUpdateWidget(covariant TodoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorType != widget.colorType) {
      _selectedColorType = widget.colorType;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontFamily: 'PretendardRegular',
      decoration:
      widget.isDone ? TextDecoration.lineThrough : TextDecoration.none,
      color: widget.isDone ? Middle_GREY_COLOR : Colors.black,
      decorationColor: widget.isDone ? Middle_GREY_COLOR : Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: widget.isColorPickerEnabled
                  ? () => _openColorPicker(context)
                  : null,
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
              child: GestureDetector(
                onTap: widget.onEditPressed,
                child: Text(widget.content, style: textStyle),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final db = LocalDatabaseSingleton.instance;
                final todo = await db.getTodoById(widget.scheduleId);
                if (todo == null) return;

                if (!mounted) return; //

                final result = await showModalBottomSheet<dynamic>(
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
                      (context) => TodoAlarm(
                    currentDate: todo.date,
                    todoId: widget.scheduleId,
                    onDataChanged: widget.onDataChanged,
                  ),
                );

                if (result != null && result is DateTime) {
                  widget.onDateChanged?.call(widget.scheduleId, result);
                } else if (result != null && result == 0) {
                  await db.updateTodo(
                    TodosCompanion(
                      id: Value(widget.scheduleId),
                      alarmMinutes: Value(null),
                    ),
                  );
                  await NotificationService().cancelNotification(
                    widget.scheduleId,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('알람이 삭제되었습니다!')));
                  }
                } else if (result != null && result is int && result > 0) {
                  final minutes = result;

                  await db.updateTodo(
                    TodosCompanion(
                      id: Value(widget.scheduleId),
                      alarmMinutes: Value(minutes),
                    ),
                  );
                  final updatedTodo = await db.getTodoById(widget.scheduleId);
                  if (updatedTodo == null) return;
                  final todoTime = updatedTodo.date;

                  final notificationTime = todoTime.subtract(
                    Duration(minutes: minutes),
                  );

                  if (notificationTime.isAfter(DateTime.now())) {
                    await NotificationService().cancelNotification(updatedTodo.id);
                    await NotificationService().scheduleNotification(
                      id: updatedTodo.id,
                      title: '오늘의 할 일!',
                      body: updatedTodo.content,
                      scheduledTime: notificationTime,
                      payload: 'todo_${updatedTodo.id}',
                    );
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${minutes}분 전 알람이 설정되었습니다!')),
                    );
                  }
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
              value: widget.isDone,
              onChanged: (bool? value) async {
                if (widget.onStatusChanged != null) {
                  await widget.onStatusChanged!();
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
    showModalBottomSheet<ColorType>(
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
        onColorSelected: (colorType) =>
            setState(() => _selectedColorType = colorType),
      ),
    ).then((selectedColor) async {
      if (selectedColor != null) {
        try {
          final db = LocalDatabaseSingleton.instance;
          await db.updateCategoryAndChildrenColor(
            categoryId: widget.scheduleId,
            newColor: selectedColor,
          );

          widget.onDataChanged?.call();
        } catch (e) {
          print("카테고리 색상 변경 실패: $e");
          if (mounted) {
            setState(() => _selectedColorType = widget.colorType);
          }
        }
      } else {
        if (mounted) {
          setState(() => _selectedColorType = widget.colorType);
        }
      }
    });
  }
}