import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import '../models/category_item.dart';
import '../screen/category_screen.dart';
import 'package:ohmo/services/notification_service.dart';

class TodoBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Future<void> Function()? onTodoAdded;
  final Future<void> Function()? onDataChanged;

  const TodoBottomSheet({
    Key? key,
    required this.selectedDate,
    this.onTodoAdded,
    this.onDataChanged,
  }) : super(key: key);

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  bool isChecked = false;
  DateTime get selectedDate => widget.selectedDate;

  List<CategoryItem> todos = [];
  int? selectedCategoryId;
  final TextEditingController contentController = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    String selectedDateStr = DateFormat('M월 d일').format(selectedDate);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "날짜 및 시간",
                    style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
                  ),
                  _buildAlarmToggleSection(),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDateStr,
                    style: TextStyle(fontSize: 16, fontFamily: 'PretendardRegular'),
                  ),
                  _buildTimePickerButton(),
                ],
              ),
              SizedBox(height: 16),
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

  Widget _buildAlarmToggleSection() {
    return Row(
      children: [
        Text(
          "알람",
          style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
        ),
        CupertinoSwitch(
          value: isChecked,
          onChanged: (value) => setState(() => isChecked = value),
          activeColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildTimePickerButton() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
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
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
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
        if (todos.isEmpty)
          Center(
            child: Text(
              "투두 카테고리를 설정해볼까요?",
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
        children: todos.map((category) {
          final isSelected = category.id == selectedCategoryId;
          Color circleColor;
          try {
            circleColor = ColorManager.getColor(
              ColorTypeExtension.fromString(
                category.colorType ?? 'pinkLight',
              ),
            );
          } catch (_) {
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
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
        if (selectedTime == null ||
            contentController.text.isEmpty ||
            selectedCategoryId == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("모든 필드를 입력해주세요")));
          return;
        }

        try {
          final db = LocalDatabaseSingleton.instance;
          final minutes = selectedTime!.hour * 60 + selectedTime!.minute;

          final selectedCategory = todos.firstWhere(
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

          final fullTodoDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime!.hour,
            selectedTime!.minute,
          );

          final id = await db.insertTodo(
            TodosCompanion.insert(
              content: contentController.text,
              colorType: drift.Value(colorIndex),
              categoryId: drift.Value(selectedCategoryId!),
              scheduleType: drift.Value('TO_DO'),
              timeMinutes: drift.Value(minutes),
              isDone: drift.Value(false),
              date: fullTodoDate,
            ),
          );

          if (isChecked) {
            final notificationTime = fullTodoDate; // 정시 알람

            if (notificationTime.isAfter(DateTime.now())) {
              await NotificationService().scheduleNotification(
                id: id, // 투두의 ID를 알람 ID로 사용
                title: '오늘의 할 일!',
                body: contentController.text,
                scheduledTime: notificationTime,
                payload: 'todo_$id', // 'todo_' 접두사를 붙여 구분
              );
            }
          }

          if (widget.onTodoAdded != null) await widget.onTodoAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("투두 등록 완료!")));
        } catch (e) {
          print('투두 저장 실패: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("투두 저장 실패")));
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
      final localDb = LocalDatabaseSingleton.instance;
      final categoryRepo = LocalCategoryRepository(localDb);

      final loadedTodos = await categoryRepo.fetchCategories(
        scheduleType: 'TO_DO',
      );
      setState(() {
        todos = loadedTodos;
        if (todos.isNotEmpty) selectedCategoryId = todos.first.id;
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }
}