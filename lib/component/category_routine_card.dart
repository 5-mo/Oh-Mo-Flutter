import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/const/colors.dart';
import '../db/drift_database.dart';
import '../services/notification_service.dart';
import 'alarm_bottom_sheet.dart';
import 'color_palette_bottom_sheet.dart';

class CategoryRoutineCard extends StatefulWidget {
  final String content;
  final Function(String) onEdit;
  final bool showCheckbox;
  final Widget Function(BuildContext)? deletePopupBuilder;
  final ColorType colorType;
  final int scheduleId;
  final bool isDone;
  final Future<void> Function()? onStatusChanged;
  final VoidCallback? onDataChanged;
  final bool isColorPickerEnabled;

  const CategoryRoutineCard({
    required this.content,
    required this.onEdit,
    required this.colorType,
    required this.scheduleId,
    this.showCheckbox = true,
    this.deletePopupBuilder,
    required this.isDone,
    this.onStatusChanged,
    this.onDataChanged,
    this.isColorPickerEnabled = true,
    Key? key,
  }) : super(key: key);

  @override
  _CategoryRoutineCardState createState() => _CategoryRoutineCardState();
}

class _CategoryRoutineCardState extends State<CategoryRoutineCard> {
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
  void didUpdateWidget(covariant CategoryRoutineCard oldWidget) {
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
              onTap:
                  widget.isColorPickerEnabled
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
              child:
                  _isEditing
                      ? TextField(
                        controller: _controller,
                        style: textStyle,
                        autofocus: true,
                        onSubmitted: (value) async {
                          setState(() => _isEditing = false);
                          widget.onEdit(value);

                          final db = LocalDatabaseSingleton.instance;
                          await db.updateRoutine(
                            RoutinesCompanion(
                              id: Value(widget.scheduleId),
                              content: Value(value),
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
                        child: Text(widget.content, style: textStyle),
                      ),
            ),

            GestureDetector(
              onTap: () async {
                final int? minutes = await showModalBottomSheet<int>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(59),
                      topLeft: Radius.circular(59),
                    ),
                  ),
                  builder:
                      (context) => RoutineAlarm(
                        routineId: widget.scheduleId,
                        onDataChanged: widget.onDataChanged,
                      ),
                );

                if (minutes != null) {
                  final db = LocalDatabaseSingleton.instance;
                  await db.updateRoutine(
                    RoutinesCompanion(
                      id: Value(widget.scheduleId),
                      alarmMinutes: Value(minutes),
                    ),
                  );
                  final routine = await db.getRoutineById(widget.scheduleId);
                  if (routine == null ||
                      routine.weekDays == null ||
                      routine.endDate == null ||
                      routine.timeMinutes == null) {
                    return;
                  }
                  final weekDays =
                      routine.weekDays!.split(',').map(int.parse).toList();

                  DateTime today = DateTime.now();
                  DateTime startDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  for (var i = 0; i < 365; i++) {
                    DateTime currentDay = startDate.add(Duration(days: i));
                    if (currentDay.isAfter(routine.endDate!)) break;

                    if (weekDays.contains(currentDay.weekday)) {
                      final routineTime = DateTime(
                        currentDay.year,
                        currentDay.month,
                        currentDay.day,
                      ).add(Duration(minutes: routine.timeMinutes!));

                      final notificationTime = routineTime.subtract(
                        Duration(minutes: minutes),
                      );

                      if (notificationTime.isBefore(DateTime.now())) continue;

                      int uniqueNotificationId =
                          widget.scheduleId * 100000000 +
                          notificationTime.year * 10000 +
                          notificationTime.month * 100 +
                          notificationTime.day;

                      await NotificationService().scheduleNotification(
                        id: uniqueNotificationId,
                        title: '오늘의 루틴 시간!',
                        body: routine.content,
                        scheduledTime: notificationTime,
                        payload: widget.scheduleId.toString(),
                      );
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${minutes}분 전으로 전체 알람이 설정되었습니다!')),
                  );
                }
              },
              child: SvgPicture.asset(
                'android/assets/images/routine_alarm.svg',
              ),
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
                      final db = LocalDatabaseSingleton.instance;
                      await db.toggleRoutineStatus(widget.scheduleId);

                      if (widget.onStatusChanged != null) {
                        await widget.onStatusChanged!();
                      }
                    } catch (e) {
                      print('루틴 상태 변경 실패: $e');
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
      builder:
          (context) => ColorPaletteBottomSheet(
            selectedColorType: _selectedColorType,
            onColorSelected:
                (colorType) => setState(() => _selectedColorType = colorType),
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
          setState(() => _selectedColorType = widget.colorType);
        }
      } else {
        setState(() => _selectedColorType = widget.colorType);
      }
    });
  }
}
