import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/services/category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_item.dart';
import '../screen/category_screen.dart';
import 'package:ohmo/services/notification_service.dart';
import 'package:ohmo/services/todo_service.dart';

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
  int? _existingAlarmMinutes;

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
    } else {
      print('[TodoSheet] 신규 등록 모드');
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
      _existingAlarmMinutes = todo.alarmMinutes;

      if (todo.timeMinutes != null) {
        selectedTime = TimeOfDay(
          hour: todo.timeMinutes! ~/ 60,
          minute: todo.timeMinutes! % 60,
        );
        isChecked = true;
      } else {
        selectedTime = null;
        isChecked = false;
      }

      if (todo.categoryId != null) {
        try {
          final matchedCategory = todos.firstWhere(
            (cat) => cat.id == todo.categoryId,
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
          }
        } catch (e) {
          selectedCategoryId = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    String selectedDateStr = DateFormat('M월         d일').format(_currentDate);

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
    final displayTodos =
        todos.where((cat) => cat.categoryName != 'default').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "카테고리",
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
        ),
        SizedBox(height: 10),
        if (displayTodos.isEmpty)
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
          _buildCategoryChoiceChips(displayTodos),
        SizedBox(height: 10),
        Center(child: SizedBox(height: 5)),
      ],
    );
  }

  Widget _buildCategoryChoiceChips(List<CategoryItem> filteredTodos) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...filteredTodos.map((category) {
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "내용",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardBold',
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PretendardRegular',
                  color: Color(0xFFE04747),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: contentController,
            decoration: const InputDecoration(
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
        final String pureContent = contentController.text.trim();
        if (pureContent.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("내용을 입력해주세요")));
          return;
        }

        if (isChecked && selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("알람을 켜려면 '시간 선택'은 필수입니다.")),
          );
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        bool isCalendarSettingOn = prefs.getBool('calendar_noti') ?? true;
        bool isAllOn = prefs.getBool('all_noti') ?? true;

        if (isChecked && !isCalendarSettingOn || !isAllOn) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("현재 '일정 알림' 설정이 꺼져 있어 알람이 울리지 않습니다. 설정 화면을 확인해 주세요."),
            duration: Duration(seconds: 2),
          ),
          );
        }

        try {
          setState(() => _isLoading = true);

          int finalLocalCategoryId;
          int realServerId;
          int colorIndex = 0;

          if (selectedCategoryId != null) {
            finalLocalCategoryId = selectedCategoryId!;
            final localCategory = todos.firstWhere(
              (c) => c.id == selectedCategoryId,
            );
            colorIndex =
                ColorTypeExtension.fromString(
                  localCategory.colorType ?? 'pinkLight',
                ).index;
            realServerId = finalLocalCategoryId;
          } else {
            final defaultCat = todos.firstWhere(
              (cat) => cat.categoryName == 'default',
              orElse:
                  () => CategoryItem(
                    id: -1,
                    categoryName: 'default',
                    colorType: 'black',
                    scheduleType: 'TO_DO',
                  ),
            );
            if (defaultCat.id == -1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("기본 카테고리 정보를 불러오지 못했습니다.")),
              );
              setState(() => _isLoading = false);
              return;
            }
            finalLocalCategoryId = defaultCat.id;
            realServerId = defaultCat.id;
            colorIndex = ColorType.uncategorizedBlack.index;
          }

          final String dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
          String? timeStr;
          int? dbTimeMinutes;
          DateTime fullTodoDate;

          if (selectedTime != null) {
            timeStr =
                "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
            dbTimeMinutes = selectedTime!.hour * 60 + selectedTime!.minute;
            fullTodoDate = DateTime(
              _currentDate.year,
              _currentDate.month,
              _currentDate.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );
          } else {
            timeStr = null;
            dbTimeMinutes = null;
            fullTodoDate = DateTime(
              _currentDate.year,
              _currentDate.month,
              _currentDate.day,
            );
          }

          final todoService = TodoService();
          final db = LocalDatabaseSingleton.instance;

          if (widget.todoIdToEdit != null) {
            final existingTodo = await db.getTodoById(widget.todoIdToEdit!);
            final int? serverScheduleId = existingTodo?.scheduleId;

            if (serverScheduleId != null && serverScheduleId != 0) {
              bool isServerSuccess = await todoService.updateTodo(
                scheduleId: serverScheduleId,
                categoryId: realServerId,
                content: pureContent,
                date: dateStr,
                time: timeStr,
                alarmTime: isChecked ? timeStr : null,
              );
            }

            await db.updateTodo(
              TodosCompanion(
                id: drift.Value(widget.todoIdToEdit!),
                content: drift.Value(pureContent),
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(finalLocalCategoryId),
                timeMinutes: drift.Value(dbTimeMinutes),
                date: drift.Value(fullTodoDate),
              ),
            );

            await NotificationService().cancelNotification(
              widget.todoIdToEdit!,
            );
            if (isChecked && fullTodoDate.isAfter(DateTime.now())) {
              await _registerNotification(
                widget.todoIdToEdit!,
                fullTodoDate,
                _existingAlarmMinutes,
              );
            }
          } else {
            final int? newServerTodoId = await todoService.registerTodo(
              categoryId: realServerId,
              time: timeStr,
              alarm: isChecked,
              content: pureContent,
              date: dateStr,
            );

            final newLocalId = await db.insertTodo(
              TodosCompanion.insert(
                scheduleId: drift.Value(newServerTodoId),
                todoServerId: drift.Value(newServerTodoId),
                content: pureContent,
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(finalLocalCategoryId),
                scheduleType: drift.Value('TO_DO'),
                timeMinutes: drift.Value(dbTimeMinutes),
                isDone: drift.Value(false),
                date: fullTodoDate,
              ),
            );

            if (isChecked && fullTodoDate.isAfter(DateTime.now())) {
              await _registerNotification(newLocalId, fullTodoDate, 0);
            }

          }
          if (widget.onTodoAdded != null) await widget.onTodoAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("저장 완료!")));
          }
        } catch (e) {
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

  Future<void> _registerNotification(
    int id,
    DateTime todoTime,
    int? minutesBefore,
  ) async {
    final notificationTime = todoTime.subtract(
      Duration(minutes: minutesBefore ?? 0),
    );

    if (notificationTime.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: id,
        title: '오늘의 할 일!',
        body: contentController.text,
        scheduledTime: notificationTime,
        payload: 'todo_$id',
      );

      final db = LocalDatabaseSingleton.instance;
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
      } catch (e) {
        print('알림함 DB 저장 실패 :$e');
      }
    }
  }

  Future<void> _loadCategories() async {
    final localDb = LocalDatabaseSingleton.instance;
    final categoryRepo = LocalCategoryRepository(localDb);
    final categoryService = CategoryService();

    try {
      final serverCategories = await categoryService.getCategories('TO_DO');

      final currentLocalCategories = await categoryRepo.fetchCategories(
        scheduleType: 'TO_DO',
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
              type: 'TO_DO',
              color: localColor,
            );
          } else {
            final existingItem = currentLocalCategories.firstWhere(
              (e) => e.categoryName == name,
            );
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
          }
        }
      }
    } catch (e) {
      print('카테고리 동기화 실패 (인터넷 문제 등): $e');
    } finally {
      final loadedTodos = await categoryRepo.fetchCategories(
        scheduleType: 'TO_DO',
      );
      if (mounted) {
        setState(() {
          todos = loadedTodos;
        });
      }
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
}
