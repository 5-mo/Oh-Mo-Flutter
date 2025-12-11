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
      print("--- [에러] 루틴 정보를 찾을 수 없습니다. (ID: $routineId) ---");
      return;
    }

    print("--- [디버깅] 루틴 로드 성공: ${routine.content} ---");

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
                  return _dayMapReverse[parsed];
                })
                .where((day) => day != null)
                .cast<String>()
                .toList();
      }

      if (routine.timeMinutes != null) {
        selectedTime = TimeOfDay(
          hour: routine.timeMinutes! ~/ 60,
          minute: routine.timeMinutes! % 60,
        );
      }

      if (routines.any((cat) => cat.id == routine.categoryId)) {
        selectedCategoryId = routine.categoryId;
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

  Widget _buildRequiredTitle(String text, {double fontSize = 14}) {
    return RichText(
      text: TextSpan(
        children: [
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
                  Text(
                    "루틴 반복 요일",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'PretendardBold',
                    ),
                  ),
                  SizedBox(width: 155),
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
          child: Text(
            selectedEndDate != null
                ? "${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}"
                : '종료 날짜',
            style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "카테고리",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        SizedBox(height: 10),
        if (routines.isEmpty)
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
          ...routines.map((category) {
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
        Text(
          "내용",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("내용과 반복 요일은 필수입니다.")));
          return;
        }
        if (isChecked && selectedTime == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("알람을 켜려면 '시간 선택'은 필수입니다.")));
          return;
        }
        if (isChecked && selectedEndDate == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("알람을 켜려면 '종료 날짜'는 필수입니다.")));
          return;
        }

        try {
          setState(() => _isLoading = true);
          final db = LocalDatabaseSingleton.instance;

          final startDate = widget.selectedDate ?? DateTime.now();
          final endDateToSave = selectedEndDate ?? DateTime(3000, 12, 31);
          final String dateStr = DateFormat('yyyy-MM-dd').format(endDateToSave);
          final routineWeekEng = _convertDaysToEng(selectedDays);
          String timeStr = "00:00";
          final String weekString = getRoutineWeek().join(',');

          int? minutes;
          if (selectedTime != null) {
            minutes = selectedTime!.hour * 60 + selectedTime!.minute;
            final now = DateTime.now();
            final dt = DateTime(
              now.year,
              now.month,
              now.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );
            timeStr = DateFormat('HH:mm').format(dt);
          }

          String? alarmTimeStr;
          int? alarmMinutesValue;
          if (isChecked && selectedTime != null) {
            alarmTimeStr = timeStr;
            alarmMinutesValue = 0;
          }
          int realServerCategoryId = selectedCategoryId ?? 0;
          int colorIndex = 0;

          if (widget.routineIdToEdit != null) {
            if (_originalWeekDaysString != weekString) {
              final newRoutineData = RoutinesCompanion(
                content: drift.Value(contentController.text),
                colorType: drift.Value(colorIndex),
                endDate: drift.Value(endDateToSave),
                timeMinutes: drift.Value(minutes),
                weekDays: drift.Value(weekString),
                categoryId: drift.Value(selectedCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
              );
              setState(() => _isLoading = false);
              _showSplitRoutinePopup(db, newRoutineData);
              return;
            }

            await db.updateRoutine(
              RoutinesCompanion(
                id: drift.Value(widget.routineIdToEdit!),
                content: drift.Value(contentController.text),
                colorType: drift.Value(colorIndex),
                endDate: drift.Value(endDateToSave),
                timeMinutes: drift.Value(minutes),
                weekDays: drift.Value(weekString),
                categoryId: drift.Value(selectedCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
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
                categoryId: drift.Value(selectedCategoryId),
                alarmMinutes: drift.Value(alarmMinutesValue),
                isSynced: drift.Value(false),
                routineId: drift.Value(0),
              ),
            );

            await _updateNotifications(tempLocalId);

            print(
              "📤 [서버 전송 시작] 내용: ${contentController.text}, 카테고리ID: $realServerCategoryId",
            );

            try {
              final routineService = RoutineService();

              final int? realServerId = await routineService.registerRoutine(
                categoryId: realServerCategoryId,
                time: timeStr,
                alarmTime: alarmTimeStr,
                content: contentController.text,
                date: dateStr,
                routineWeek: routineWeekEng,
              );

              if (realServerId != null) {
                print("✅ [서버 업로드 성공] 서버ID 발급됨: $realServerId");

                print("🔄 [ID SWAP] 로컬($tempLocalId) -> 서버($realServerId)");

                final localData = await db.getRoutineById(tempLocalId);

                if (localData != null) {
                  await db.deleteRoutine(tempLocalId);

                  await _cancelAllScheduledNotifications(tempLocalId);

                  await db
                      .into(db.routines)
                      .insert(
                        localData
                            .toCompanion(true)
                            .copyWith(
                              id: drift.Value(realServerId),
                              routineId: drift.Value(realServerId),
                            ),
                      );

                  await _cancelAllScheduledNotifications(tempLocalId);
                  await _updateNotifications(realServerId);
                }
              }
            } catch (serverError) {
              print("❌ 서버 전송 실패: $serverError (로컬 데이터는 유지됨)");
            }
          }

          if (widget.onRoutineAdded != null) await widget.onRoutineAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("루틴이 저장되었습니다.")));
          }
        } catch (e) {
          print('저장 중 치명적 오류: $e');
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
          }
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
                  ? CupertinoActivityIndicator(color: Colors.white)
                  : Text(
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

    setState(() => _isLoading = true);

    try {
      final oldRoutineEndDate = normalizedSplitDate.subtract(Duration(days: 1));
      await db.updateRoutine(
        RoutinesCompanion(
          id: drift.Value(widget.routineIdToEdit!),
          endDate: drift.Value(oldRoutineEndDate),
        ),
      );

      final newRoutineId = await db.insertRoutine(
        newRoutineData.copyWith(
          startDate: drift.Value(normalizedSplitDate),
          groupId: drift.Value(widget.groupId),
          isDone: drift.Value(false),
        ),
      );

      await _updateNotifications(widget.routineIdToEdit!);
      await _updateNotifications(newRoutineId);

      if (widget.onRoutineAdded != null) await widget.onRoutineAdded!();
      if (widget.onDataChanged != null) await widget.onDataChanged!();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("루틴이 분할 저장되었습니다.")));
      Navigator.of(context).pop();
    } catch (e) {
      print('루틴 분할 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('루틴 분할 저장 실패')));
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
      Object.hash(routineId, currentDay.year, currentDay.month, currentDay.day) & 0x7FFFFFFF;

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
          serverCategories.map((e) => e['categoryName']).toSet();
      final localCategoryNames =
          currentLocalCategories.map((e) => e.categoryName).toSet();

      if (serverCategories.isNotEmpty) {
        for (var item in serverCategories) {
          final String name = item['categoryName'];
          final String rawColor = item['color'] ?? 'pinkLight';
          final String localColor = _mapServerColorToLocal(rawColor);

          if (!localCategoryNames.contains(name)) {
            await categoryRepo.insertCategory(
              name: name,
              type: 'ROUTINE',
              color: localColor,
            );
            print('루틴 동기화: 서버에서 [$name] 가져옴');
          } else {
            final existingItem = currentLocalCategories.firstWhere(
              (e) => e.categoryName == name,
            );
            if (existingItem.colorType != localColor) {
              await categoryRepo.updateCategoryColor(
                existingItem.id,
                localColor,
              );
              print(
                '루틴 동기화: 색상 업데이트 [$name] ${existingItem.colorType} -> $localColor',
              );
            }
          }
        }

        for (var localItem in currentLocalCategories) {
          if (!serverCategoryNames.contains(localItem.categoryName)) {
            await categoryRepo.deleteCategory(localItem.id);
          }
        }
      }
    } catch (e) {
      print('카테고리 동기화 실패 (인터넷 문제 등): $e');
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
