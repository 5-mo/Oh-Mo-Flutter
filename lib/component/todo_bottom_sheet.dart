import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
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
  final int? todoIdToEdit;

  const TodoBottomSheet({
    Key? key,
    required this.selectedDate,
    this.onTodoAdded,
    this.onDataChanged,
    this.todoIdToEdit,
  }) : super(key: key);

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  bool isChecked = false;

  late DateTime _currentDate;

  List<CategoryItem> todos = [];
  int? selectedCategoryId;
  final TextEditingController contentController = TextEditingController();
  TimeOfDay? selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadCategories();

    if (widget.todoIdToEdit != null) {
      await _loadDataForEdit(widget.todoIdToEdit!);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDataForEdit(int todoId) async {
    final db = LocalDatabaseSingleton.instance;
    final todo = await db.getTodoById(todoId);
    if (todo == null) return;

    setState(() {
      contentController.text = todo.content;
      _currentDate = todo.date;

      if (todo.timeMinutes != null) {
        if (todo.timeMinutes == 0 &&
            (todo.date.hour != 0 || todo.date.minute != 0)) {
          selectedTime = TimeOfDay.fromDateTime(todo.date);
        } else if (todo.timeMinutes! > 0) {
          selectedTime = null;
        }
        isChecked = true;
        if (todo.date.hour != 0 || todo.date.minute != 0) {
          selectedTime = TimeOfDay.fromDateTime(todo.date);
        } else {
          selectedTime = null;
        }
      } else {
        isChecked = false;
        if (todo.date.hour != 0 || todo.date.minute != 0) {
          selectedTime = TimeOfDay.fromDateTime(todo.date);
        } else {
          selectedTime = null;
        }
      }
      if (todos.any((cat) => cat.id == todo.categoryId)) {
        selectedCategoryId = todo.categoryId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    String selectedDateStr = DateFormat('M월  d일  ').format(_currentDate);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "날짜 및 시간",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'PretendardBold',
                    ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'PretendardRegular',
                    ),
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
        SizedBox(height: 10),
        if (todos.isEmpty)
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "투두 카테고리를 설정해볼까요?",
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
          ...todos.map((category) {
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
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
                        blurRadius: 4,
                      ),
                    ],
                    border: Border.all(color: Colors.transparent, width: 0),
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
          ).then((_) => _loadInitialData());
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
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
        if (contentController.text.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("내용을 입력해주세요")));
          return;
        }
        if (isChecked && selectedTime == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("알람을 켜려면 '시간 선택'은 필수입니다.")));
          return;
        }

        try {
          final db = LocalDatabaseSingleton.instance;
          final int? alarmMinutesValue;
          if (isChecked) {
            alarmMinutesValue = 0;
          } else {
            alarmMinutesValue = null;
          }
          int colorIndex = 0;

          int? categoryId = selectedCategoryId;

          if (selectedCategoryId != null) {
            final selectedCategory = todos.firstWhere(
              (c) => c.id == selectedCategoryId,
            );
            try {
              colorIndex =
                  ColorTypeExtension.fromString(
                    selectedCategory.colorType!,
                  ).index;
            } catch (_) {
              colorIndex = 0;
            }
          } else {
            colorIndex = ColorType.uncategorizedBlack.index;
          }

          final DateTime fullTodoDate;
          if (selectedTime != null) {
            fullTodoDate = DateTime(
              _currentDate.year,
              _currentDate.month,
              _currentDate.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );
          } else {
            fullTodoDate = _currentDate;
          }

          int todoId;

          if (widget.todoIdToEdit != null) {
            await db.updateTodo(
              TodosCompanion(
                id: drift.Value(widget.todoIdToEdit!),
                content: drift.Value(contentController.text),
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(categoryId),
                timeMinutes: drift.Value(alarmMinutesValue),
                date: drift.Value(fullTodoDate),
              ),
            );
            todoId = widget.todoIdToEdit!;
          } else {
            todoId = await db.insertTodo(
              TodosCompanion.insert(
                content: contentController.text,
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(categoryId),
                scheduleType: drift.Value('TO_DO'),
                timeMinutes: drift.Value(alarmMinutesValue),
                isDone: drift.Value(false),
                date: fullTodoDate,
              ),
            );
          }

          await NotificationService().cancelNotification(todoId);

          if (isChecked && selectedTime != null) {
            final notificationTime = fullTodoDate;

            if (notificationTime.isAfter(DateTime.now())) {
              await NotificationService().scheduleNotification(
                id: todoId,
                title: '오늘의 할 일!',
                body: contentController.text,
                scheduledTime: notificationTime,
                payload: 'todo_$todoId',
              );
              try {
                await db
                    .into(db.notifications)
                    .insert(
                      NotificationsCompanion.insert(
                        type: 'calender',
                        content: '[To-do] ${contentController.text}',
                        timestamp: notificationTime,
                        isRead: const drift.Value(false),
                      ),
                    );
                print("DB 알림 테이블 저장 완료");
              } catch (e) {
                print("DB 알림 테이블 저장 실패: $e");
              }
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

  Future<void> _loadCategories() async {
    try {
      final localDb = LocalDatabaseSingleton.instance;
      final categoryRepo = LocalCategoryRepository(localDb);

      final loadedTodos = await categoryRepo.fetchCategories(
        scheduleType: 'TO_DO',
      );
      todos = loadedTodos;
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }
}
