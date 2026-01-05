import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/screen/category_screen.dart';
import 'package:ohmo/services/sync_service.dart';
import '../db/drift_database.dart';
import '../models/category_item.dart';
import 'package:ohmo/services/notification_service.dart';
import 'package:intl/intl.dart';

import '../services/category_service.dart';
import '../services/routine_service.dart';

class RoutineBottomSheet extends StatefulWidget {
  final int? groupId;
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onDataChanged;
  final int? routineIdToEdit;
  final DateTime? selectedDate;

  const RoutineBottomSheet({
    Key? key,
    this.groupId,
    this.onRoutineAdded,
    this.onDataChanged,
    this.routineIdToEdit,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<RoutineBottomSheet> createState() => _RoutineBottomSheetState();
}

class _RoutineBottomSheetState extends State<RoutineBottomSheet> {
  final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
  final Map<int, String> _dayMapReverse = {
    1: '월',
    2: '화',
    3: '수',
    4: '목',
    5: '금',
    6: '토',
    7: '일',
  };
  List<CategoryItem> routines = [];
  int? selectedCategoryId;
  List<String> selectedDays = [];

  final TextEditingController contentController = TextEditingController();
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;
  bool _isLoading = false;
  String? _originalWeekDaysString;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadCategories();

    if (widget.routineIdToEdit != null) {
      await _loadDataForEdit(widget.routineIdToEdit!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDataForEdit(int routineId) async {
    final db = LocalDatabaseSingleton.instance;
    final routine =
        await (db.select(db.routines)..where(
          (tbl) => tbl.id.equals(routineId) | tbl.routineId.equals(routineId),
        )).getSingleOrNull();

    if (routine == null) {
      print("루틴 정보를 찾을 수 없습니다. ID: $routineId");
      return;
    }

    setState(() {
      contentController.text = routine.content;

      if (routine.endDate == null || routine.endDate!.year == 3000) {
        selectedEndDate = null;
      } else {
        selectedEndDate = routine.endDate;
      }

      _originalWeekDaysString = routine.weekDays;
      if (routine.weekDays != null && routine.weekDays!.isNotEmpty) {
        selectedDays =
            routine.weekDays!
                .split(',')
                .map((e) {
                  final trimmed = e.trim();
                  final parsed = int.tryParse(trimmed);
                  return parsed != null ? _dayMapReverse[parsed] : null;
                })
                .whereType<String>()
                .toList();
      }

      if (routine.timeMinutes != null && routine.timeMinutes != 0) {
        selectedTime = TimeOfDay(
          hour: routine.timeMinutes! ~/ 60,
          minute: routine.timeMinutes! % 60,
        );
      } else {
        selectedTime = null;
      }
      if (routine.categoryId != null) {
        try {
          final matchedCategory = routines.firstWhere(
            (cat) => cat.serverId == routine.categoryId,
            orElse:
                () => CategoryItem(
                  id: -1,
                  categoryName: 'unknown',
                  colorType: 'black',
                  scheduleType: '',
                ),
          );
          if (matchedCategory.id != -1) {
            if (matchedCategory.categoryName == 'default') {
              selectedCategoryId = null;
            } else {
              selectedCategoryId = matchedCategory.id;
            }
          } else {
            selectedCategoryId = null;
          }
        } catch (e) {
          selectedCategoryId = null;
        }
      } else {
        selectedCategoryId = null;
      }

      isChecked = routine.alarmMinutes != null;
    });
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  List<String> getRoutineWeek() {
    Map<String, int> dayMap = {
      "월": 1,
      "화": 2,
      "수": 3,
      "목": 4,
      "금": 5,
      "토": 6,
      "일": 7,
    };
    final weekNumbers = selectedDays.map((d) => dayMap[d]!.toString()).toList();
    return weekNumbers;
  }

  List<String> _convertDaysToEng(List<String> koreanDays) {
    const map = {
      '월': 'MONDAY',
      '화': 'TUESDAY',
      '수': 'WEDNESDAY',
      '목': 'THURSDAY',
      '금': 'FRIDAY',
      '토': 'SATURDAY',
      '일': 'SUNDAY',
    };
    return koreanDays.map((day) => map[day] ?? 'MONDAY').toList();
  }

  Widget _buildRequiredTitle(
    String text, {
    double fontSize = 14,
    String fontFamily = 'PretnedardBold',
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: fontFamily,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: ' *',
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'PretendardRegular',
              color: Color(0xFFE04747),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_isLoading) {
      return Container(
        height: 300,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildRequiredTitle(
                    "루틴 반복 요일",
                    fontSize: 16,
                    fontFamily: 'PretendardBold',
                  ),
                  const Spacer(),
                  _buildAlarmToggleSection(),
                ],
              ),
              _buildRepeatDaysSection(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildRoutineTimeButton(),
                      SizedBox(width: 20),
                      _buildRoutineClosingDateButton(),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25),
              _buildCategorySelectionSection(),
              _buildContentInputSection(),
              SizedBox(height: 20),
              _buildSaveButton(),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          children:
              weekDays
                  .map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildDayButton(day),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildDayButton(String day) {
    final selected = selectedDays.contains(day);
    return GestureDetector(
      onTap: () => toggleDay(day),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardBold',
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmToggleSection() {
    return Row(
      children: [
        Text(
          "알람",
          style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
        ),
        Transform.scale(
          scale: 1,
          child: CupertinoSwitch(
            value: isChecked,
            onChanged: (value) => setState(() => isChecked = value),
            activeColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineClosingDateButton() {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedEndDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(3000),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.black,
                colorScheme: const ColorScheme.light(primary: Colors.black),
                buttonTheme: const ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) setState(() => selectedEndDate = pickedDate);
      },
      child: Container(
        width: 154,
        height: 37,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child:
              selectedEndDate != null
                  ? Text(
                    "${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                    ),
                  )
                  : const Text(
                    "종료 날짜",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildRoutineTimeButton() {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData(
                primaryColor: LIGHT_GREY_COLOR,
                timePickerTheme: TimePickerThemeData(
                  hourMinuteColor: Colors.grey[200],
                  hourMinuteTextColor: Colors.black,
                  backgroundColor: Colors.white,
                  dialHandColor: Colors.black,
                  dialBackgroundColor: Colors.grey[200],
                  dayPeriodColor: Colors.grey[200],
                  dayPeriodTextColor: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedTime != null) setState(() => selectedTime = pickedTime);
      },
      child: Container(
        width: 154,
        height: 37,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            selectedTime != null ? selectedTime!.format(context) : '시간 선택',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelectionSection() {
    final displayRoutines =
        routines.where((cat) => cat.categoryName != 'default').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "카테고리",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        SizedBox(height: 10),
        if (displayRoutines.isEmpty)
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "루틴 카테고리를 설정해볼까요?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'PretendardMedium',
                    color: Color(0xFFA5A5A5),
                  ),
                ),
                SizedBox(height: 7),
                _buildCategoryButton(),
              ],
            ),
          )
        else
          _buildCategoryChoiceChips(),
        SizedBox(height: 10),
        Center(child: SizedBox(height: 5)),
      ],
    );
  }

  Widget _buildCategoryChoiceChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...routines.where((cat) => cat.categoryName != 'default').map((
            category,
          ) {
            final isSelected = category.id == selectedCategoryId;
            final colorString = category.colorType ?? 'pinkLight';
            late Color circleColor;
            try {
              final ColorType colorType = ColorTypeExtension.fromString(
                colorString,
              );
              circleColor = ColorManager.getColor(colorType);
            } catch (e) {
              circleColor = Colors.grey;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedCategoryId = null;
                    } else {
                      selectedCategoryId = category.id;
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                      ),
                    ],
                    border: Border.all(color: Colors.transparent, width: 0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        category.categoryName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontFamily: 'PretendardRegular',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          _buildAddCategoryButton(),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CategoryScreen()),
          ).then((_) => _loadInitialData()); //
          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3),
            ],
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'android/assets/images/dashed_circle.svg',
                width: 12,
                height: 12,
              ),
              SizedBox(width: 8),
              Text(
                "추가",
                style: TextStyle(
                  color: Color(0xFF6E6767),
                  fontFamily: 'PretendardRegular',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryScreen()),
        ).then((_) => _loadInitialData());
        if (widget.onDataChanged != null) {
          widget.onDataChanged!();
        }
      },
      child: Container(
        width: 97,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            '카테고리 추가하기',
            style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredTitle("내용", fontSize: 16, fontFamily: 'PretendardBold'),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 41,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: contentController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () async {
        if (contentController.text.isEmpty || selectedDays.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("내용과 반복 요일은 필수 입력 사항입니다.")),
          );
          return;
        }

        if (isChecked && selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("알람을 켜려면 시간을 선택해야 합니다.")),
          );
          return;
        }

        try {
          setState(() => _isLoading = true);

          final DateTime now = DateTime.now();
          final DateTime endDateToSave =
              selectedEndDate ?? DateTime(now.year, now.month + 3, now.day);

          final String dateStr = DateFormat('yyyy-MM-dd').format(endDateToSave);
          final db = LocalDatabaseSingleton.instance;
          final routineService = RoutineService();

          int realServerCategoryId = 0;
          int colorIndex = ColorType.uncategorizedBlack.index;

          if (selectedCategoryId != null) {
            final selectedCat = routines.firstWhere(
              (cat) => cat.id == selectedCategoryId,
              orElse:
                  () => CategoryItem(
                    id: -1,
                    categoryName: '',
                    colorType: 'uncategorizedBlack',
                    scheduleType: '',
                  ),
            );
            realServerCategoryId = selectedCat.serverId ?? 0;
            colorIndex =
                ColorTypeExtension.fromString(
                  selectedCat.colorType ?? 'uncategorizedBlack',
                ).index;
          } else {
            final defaultCat = routines.firstWhere(
              (cat) => cat.categoryName == 'default',
              orElse:
                  () => CategoryItem(
                    id: -1,
                    categoryName: '',
                    colorType: 'uncategorizedBlack',
                    scheduleType: '',
                  ),
            );
            realServerCategoryId = defaultCat.serverId ?? 0;
            colorIndex = ColorType.uncategorizedBlack.index;
          }

          if (realServerCategoryId == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("카테고리 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요."),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          final startDate = widget.selectedDate ?? DateTime.now();
          final routineWeekEng = _convertDaysToEng(selectedDays);
          final String weekString = getRoutineWeek().join(',');

          int? minutes;
          String? timeStr;
          if (selectedTime != null) {
            minutes = selectedTime!.hour * 60 + selectedTime!.minute;
            timeStr =
                "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
          }

          String? alarmTimeStr = isChecked ? timeStr : null;
          int? alarmMinutesValue = isChecked ? 0 : null;

          if (widget.routineIdToEdit != null) {
            if (_originalWeekDaysString != weekString) {
              final newRoutineData = RoutinesCompanion(
                content: drift.Value(contentController.text),
                colorType: drift.Value(colorIndex),
                endDate: drift.Value(endDateToSave),
                timeMinutes: drift.Value(minutes),
                weekDays: drift.Value(weekString),
                categoryId: drift.Value(realServerCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
              );
              setState(() => _isLoading = false);
              _showSplitRoutinePopup(db, newRoutineData);
              return;
            }

            final routineData = await db.getRoutineById(
              widget.routineIdToEdit!,
            );
            final int? masterScheduleId = routineData?.scheduleId;

            if (masterScheduleId != null && masterScheduleId != 0) {
              final bool isServerSuccess = await routineService.updateRoutine(
                scheduleId: masterScheduleId,
                categoryId: realServerCategoryId,
                time: timeStr ?? "",
                alarmTime: alarmTimeStr,
                content: contentController.text,
                date: dateStr,
                routineWeek: routineWeekEng,
              );

              if (!isServerSuccess) {
                print("서버 수정 실패: SCHEDULE4002 등의 이유일 수 있음");
              }
            }

            await db.updateRoutine(
              RoutinesCompanion(
                id: drift.Value(widget.routineIdToEdit!),
                content: drift.Value(contentController.text),
                endDate: drift.Value(endDateToSave),
                timeMinutes: drift.Value(minutes),
                weekDays: drift.Value(weekString),
                categoryId: drift.Value(realServerCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
                colorType: drift.Value(colorIndex),
              ),
            );
            await _updateNotifications(widget.routineIdToEdit!);
          } else {
            final tempLocalId = await db.insertRoutine(
              RoutinesCompanion.insert(
                groupId: drift.Value(widget.groupId),
                content: contentController.text,
                colorType: drift.Value(colorIndex),
                isDone: drift.Value(false),
                startDate: drift.Value(startDate),
                endDate: drift.Value(endDateToSave),
                timeMinutes: drift.Value(minutes),
                weekDays: drift.Value(weekString),
                categoryId: drift.Value(realServerCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
                isSynced: drift.Value(false),
                routineId: const drift.Value.absent(),
              ),
            );
            await _updateNotifications(tempLocalId);

            String colorNameForServer = ColorType.values[colorIndex].name;
            try {
              final Map<String, int?>? serverIds = await routineService
                  .registerRoutine(
                    categoryId: realServerCategoryId,
                    time: timeStr ?? "",
                    alarmTime: alarmTimeStr,
                    content: contentController.text,
                    date: dateStr,
                    routineWeek: routineWeekEng,
                    color: colorNameForServer,
                  );

              if (serverIds != null) {
                final int? realRoutineId = serverIds['routineId'];
                final int? realScheduleId = serverIds['scheduleId'];

                print(
                  '[UI] 서버 등록 성공! RoutineID: $realRoutineId, ScheduleID: $realScheduleId',
                );

                await db.updateRoutine(
                  RoutinesCompanion(
                    id: drift.Value(tempLocalId),
                    routineId: drift.Value(realRoutineId),
                    scheduleId: drift.Value(realScheduleId),
                    isSynced: drift.Value(true),
                  ),
                );
              }
            } catch (serverError) {
              print("서버 등록 실패: $serverError");
            }
          }

          if (widget.onRoutineAdded != null) await widget.onRoutineAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("루틴이 저장되었습니다.")));
          }
        } catch (e) {
          print('저장 과정 오류: $e');
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child:
              _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text(
                    '저장하기',
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

  void _showSplitRoutinePopup(
    LocalDatabase db,
    RoutinesCompanion newRoutineData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "요일 변경",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "루틴 요일 변경 시 오늘부터 적용할까요?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'PretendardRegular',
                  color: Colors.black,
                ),
              ),
              Text(
                "이전 루틴은 그대로 저장됩니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(277, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _splitRoutine(db, newRoutineData, DateTime.now());
                },
                child: Text(
                  "오늘부터 적용하기",
                  style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(277, 43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: BorderSide(color: Colors.black.withOpacity(0.25)),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now().add(Duration(days: 1)),
                    lastDate: DateTime(3000),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.black,
                          colorScheme: const ColorScheme.light(
                            primary: Colors.black,
                          ),
                          buttonTheme: const ButtonThemeData(
                            textTheme: ButtonTextTheme.primary,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    _splitRoutine(db, newRoutineData, pickedDate);
                  }
                },
                child: Text(
                  "날짜 선택하기",
                  style: TextStyle(fontFamily: 'PretendardBold', fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _splitRoutine(
    LocalDatabase db,
    RoutinesCompanion newRoutineData,
    DateTime splitDate,
  ) async {
    final normalizedSplitDate = DateTime(
      splitDate.year,
      splitDate.month,
      splitDate.day,
    );
    final oldEndDate = normalizedSplitDate.subtract(const Duration(days: 1));
    final String oldRoutineEndDateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(oldEndDate);

    setState(() => _isLoading = true);

    try {
      final routineService = RoutineService();
      final oldRoutine = await db.getRoutineById(widget.routineIdToEdit!);

      if (oldRoutine != null &&
          oldRoutine.scheduleId != null &&
          oldRoutine.scheduleId != 0) {
        print('🔄 기존 루틴 종료일 업데이트 시도 (ID: ${oldRoutine.scheduleId})');

        int actualServerCategoryId = 0;
        try {
          final catMatch = routines.firstWhere(
            (c) =>
                c.id == oldRoutine.categoryId ||
                c.serverId == oldRoutine.categoryId,
            orElse:
                () => routines.firstWhere((c) => c.categoryName == 'default'),
          );
          actualServerCategoryId = catMatch.serverId ?? 0;
        } catch (e) {
          print('카테고리 매칭 실패: $e');
        }

        String oldTimeStr = "";
        if (oldRoutine.timeMinutes != null) {
          oldTimeStr =
              "${(oldRoutine.timeMinutes! ~/ 60).toString().padLeft(2, '0')}:${(oldRoutine.timeMinutes! % 60).toString().padLeft(2, '0')}";
        }

        final bool isPatchSuccess = await routineService.updateRoutine(
          scheduleId: oldRoutine.scheduleId!,
          categoryId: actualServerCategoryId,
          time: oldTimeStr,
          content: oldRoutine.content,
          date: oldRoutineEndDateStr,
          routineWeek: _convertDaysToEng(
            oldRoutine.weekDays!
                .split(',')
                .map((e) => _dayMapReverse[int.parse(e)]!)
                .toList(),
          ),
        );

        if (!isPatchSuccess) {
          throw Exception("기존 루틴 종료 날짜를 변경하는 데 실패했습니다. (카테고리 타입 확인 필요)");
        }

        String? newTimeStr;
        if (selectedTime != null) {
          newTimeStr =
              "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
        }

        final String newRoutineEndDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(selectedEndDate!);
        final List<String> newRoutineWeekEng = _convertDaysToEng(selectedDays);
        final String colorName =
            ColorType.values[newRoutineData.colorType.value].name;
        final Map<String, int?>? serverIds = await routineService
            .registerRoutine(
              categoryId: newRoutineData.categoryId.value ?? 0,
              time: newTimeStr ?? "",
              alarmTime: isChecked ? newTimeStr : null,
              content: contentController.text,
              date: newRoutineEndDateStr,
              routineWeek: newRoutineWeekEng,
              color: ColorType.values[newRoutineData.colorType.value].name,
            );

        if (serverIds == null) throw Exception("새 루틴 등록 실패");

        await db.transaction(() async {
          await db.updateRoutine(
            RoutinesCompanion(
              id: drift.Value(widget.routineIdToEdit!),
              endDate: drift.Value(oldEndDate),
            ),
          );

          final newLocalId = await db.insertRoutine(
            newRoutineData.copyWith(
              startDate: drift.Value(normalizedSplitDate),
              routineId: drift.Value(serverIds['routineId']),
              scheduleId: drift.Value(serverIds['scheduleId']),
              isSynced: drift.Value(true),
              groupId: drift.Value(widget.groupId),
              isDone: const drift.Value(false),
            ),
          );

          await _updateNotifications(widget.routineIdToEdit!);
          await _updateNotifications(newLocalId);
        });
        if (widget.onRoutineAdded != null) await widget.onRoutineAdded!();
        if (widget.onDataChanged != null) await widget.onDataChanged!();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("루틴이 분할 저장되었습니다.")));
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateNotifications(int routineId) async {
    try {
      final db = LocalDatabaseSingleton.instance;
      final routine = await db.getRoutineById(routineId);
      if (routine == null ||
          routine.weekDays == null ||
          routine.endDate == null ||
          routine.timeMinutes == null ||
          routine.startDate == null) {
        await _cancelAllScheduledNotifications(routineId);
        return;
      }

      await _cancelAllScheduledNotifications(routineId);

      if (isChecked) {
        final weekDays = routine.weekDays!.split(',').map(int.parse).toList();

        DateTime today = DateTime.now();
        DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

        DateTime startDate =
            routine.startDate!.isAfter(todayDateOnly)
                ? routine.startDate!
                : todayDateOnly;

        final daysToIterate = routine.endDate!.difference(startDate).inDays + 1;

        for (var i = 0; i < (daysToIterate < 0 ? 0 : daysToIterate); i++) {
          DateTime currentDay = startDate.add(Duration(days: i));

          if (weekDays.contains(currentDay.weekday)) {
            final notificationTime = DateTime(
              currentDay.year,
              currentDay.month,
              currentDay.day,
            ).add(Duration(minutes: routine.timeMinutes!));

            if (notificationTime.isBefore(DateTime.now())) continue;

            int uniqueNotificationId =
                Object.hash(routine.id, notificationTime) & 0x7FFFFFFF;

            await NotificationService().scheduleNotification(
              id: uniqueNotificationId,
              title: '오늘의 루틴 시간!',
              body: routine.content,
              scheduledTime: notificationTime,
              payload: 'routine_${routine.id}',
            );
            try {
              await db
                  .into(db.notifications)
                  .insert(
                    NotificationsCompanion.insert(
                      type: 'calender',
                      content: '[Routine] ${routine.content}',
                      timestamp: notificationTime,
                      isRead: const drift.Value(false),
                    ),
                  );
            } catch (e) {}
          }
        }
      }
    } catch (e) {
      print("Failed to update notifications in background: $e");
    }
  }

  Future<void> _cancelAllScheduledNotifications(int routineId) async {
    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, today.day);

    for (var i = 0; i < 730; i++) {
      DateTime currentDay = startDate.add(Duration(days: i));

      int uniqueNotificationId =
          Object.hash(
            routineId,
            currentDay.year,
            currentDay.month,
            currentDay.day,
          ) &
          0x7FFFFFFF;

      await NotificationService().cancelNotification(uniqueNotificationId);
    }
  }

  String _mapServerColorToLocal(String serverColor) {
    try {
      for (var type in ColorType.values) {
        if (type.name.toUpperCase() == serverColor.toUpperCase()) {
          return type.name;
        }
      }
    } catch (e) {}
    return 'pinkLight';
  }

  Future<void> _loadCategories() async {
    final localDb = LocalDatabaseSingleton.instance;
    final categoryRepo = LocalCategoryRepository(localDb);
    final categoryService = CategoryService();

    try {
      final serverCategories = await categoryService.getCategories('ROUTINE');

      final currentLocalCategories = await categoryRepo.fetchCategories(
        scheduleType: 'ROUTINE',
      );

      final serverCategoryNames =
          serverCategories
              .map((e) => e['categoryName']?.toString() ?? '')
              .toSet();
      final localCategoryNames =
          currentLocalCategories.map((e) => e.categoryName).toSet();

      if (serverCategories.isNotEmpty) {
        for (var item in serverCategories) {
          final String name = item['categoryName']?.toString() ?? '이름 없음';

          final dynamic rawId = item['categoryId'] ?? item['id'];
          final int serverId =
              (rawId is int)
                  ? rawId
                  : int.tryParse(rawId?.toString() ?? '0') ?? 0;

          if (serverId == 0) continue;

          String rawColor = item['color']?.toString() ?? 'pinkLight';

          if (name.toLowerCase().trim() == 'default') {
            rawColor = 'uncategorizedBlack';
          }

          final String localColor = _mapServerColorToLocal(rawColor);

          if (!localCategoryNames.contains(name)) {
            await categoryRepo.insertCategory(
              name: name,
              type: 'ROUTINE',
              color: localColor,
              serverCategoryId: serverId,
            );
          } else {
            final existingItem = currentLocalCategories.firstWhere(
              (e) => e.categoryName == name,
            );

            if (existingItem.serverId == null || existingItem.serverId == 0) {
              await categoryRepo.updateCategoryServerId(
                existingItem.id,
                serverId,
              );
            }

            if (existingItem.colorType != localColor) {
              await categoryRepo.updateCategoryColor(
                existingItem.id,
                localColor,
              );
            }
          }
        }

        for (var localItem in currentLocalCategories) {
          if (!serverCategoryNames.contains(localItem.categoryName)) {
            await categoryRepo.deleteCategory(localItem.id);
            print('삭제된 카테고리 로컬 제거: [${localItem.categoryName}]');
          }
        }
      }
    } catch (e) {
      print('카테고리 동기화 중 오류 발생: $e');
    } finally {
      final loadedRoutines = await categoryRepo.fetchCategories(
        scheduleType: 'ROUTINE',
      );

      if (mounted) {
        setState(() {
          routines = loadedRoutines;
        });
      }
    }
  }
}
