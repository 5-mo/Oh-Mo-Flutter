import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/screen/category_screen.dart';
import '../models/category_item.dart';

class RoutineBottomSheet extends StatefulWidget {
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onDataChanged;

  const RoutineBottomSheet({Key? key, this.onRoutineAdded, this.onDataChanged})
    : super(key: key);

  @override
  State<RoutineBottomSheet> createState() => _RoutineBottomSheetState();
}

class _RoutineBottomSheetState extends State<RoutineBottomSheet> {
  final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
  List<CategoryItem> routines = [];
  int? selectedCategoryId;
  List<String> selectedDays = [];

  final TextEditingController contentController = TextEditingController();
  DateTime? selectedEndDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRepeatDaysSection(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAlarmToggleSection(),
                  Column(
                    children: [
                      _buildRoutineClosingDateButton(),
                      SizedBox(height: 10),
                      _buildRoutineTimeButton(),
                    ],
                  ),
                ],
              ),
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
        Text(
          "루틴 반복 요일",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
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
        width: 195,
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
                : '종료 날짜 선택',
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
        width: 195,
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
        SizedBox(height: 16),
        if (routines.isEmpty)
          Center(
            child: Text(
              "루틴 카테고리를 설정해볼까요?",
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'PretendardSemiBold',
                color: DARK_GREY_COLOR,
              ),
            ),
          )
        else
          _buildCategoryChoiceChips(),
        SizedBox(height: 16),
        Center(child: _buildCategoryButton()),
      ],
    );
  }

  Widget _buildCategoryChoiceChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            routines.map((category) {
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
                  onTap: () => setState(() => selectedCategoryId = category.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border.all(
                        color: isSelected ? Colors.grey : Colors.transparent,
                        width: 2,
                      ),
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
                        SizedBox(width: 6),
                        Text(
                          category.categoryName,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCategoryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryScreen()),
        ).then((_) => _loadCategories());
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
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () async {
        if (selectedEndDate == null ||
            selectedTime == null ||
            contentController.text.isEmpty ||
            selectedDays.isEmpty ||
            selectedCategoryId == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("모든 필드를 입력해주세요")));
          return;
        }
        try {
          final db = LocalDatabase();

          final selectedCategory = routines.firstWhere(
            (c) => c.id == selectedCategoryId,
          );

          int colorIndex = 0;
          if (selectedCategory.colorType != null) {
            try {
              colorIndex =
                  ColorTypeExtension.fromString(
                    selectedCategory.colorType!,
                  ).index;
            } catch (_) {}
          }

          final minutes = selectedTime!.hour * 60 + selectedTime!.minute;
          final weekString = getRoutineWeek().join(',');

          final startDate = DateTime.now();

          final id = await db.insertRoutine(
            RoutinesCompanion.insert(
              content: contentController.text,
              colorType: drift.Value(colorIndex),
              isDone: drift.Value(false),
              startDate: drift.Value(startDate),
              endDate: drift.Value(selectedEndDate!),
              timeMinutes: drift.Value(minutes),
              weekDays: drift.Value(weekString),
              categoryId: drift.Value(selectedCategoryId!),
            ),
          );

          print('새 루틴 ID: $id');

          if (widget.onRoutineAdded != null) await widget.onRoutineAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("루틴 등록 완료!")));
        } catch (e) {
          print('루틴 저장 실패: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('루틴 저장 실패')));
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
          child: Text(
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

  void _loadCategories() async {
    try {
      final localDb = LocalDatabase();
      final categoryRepo = LocalCategoryRepository(localDb);

      final loadedRoutines = await categoryRepo.fetchCategories(
        scheduleType: 'ROUTINE',
      );

      setState(() {
        routines = loadedRoutines;
        if (routines.isNotEmpty) selectedCategoryId = routines.first.id;
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }
}
