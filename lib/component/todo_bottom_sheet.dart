import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/services/category_service.dart';
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

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    print('🚀 [TodoSheet] 초기 데이터 로드 시작');
    setState(() => _isLoading = true);

    await _loadCategories();
    print('📦 [TodoSheet] 카테고리 로드 완료. 개수: ${todos.length}');

    if (widget.todoIdToEdit != null) {
      print('✏️ [TodoSheet] 수정 모드 진입. ID: ${widget.todoIdToEdit}');
      await _loadDataForEdit(widget.todoIdToEdit!);
    } else {
      print('✨ [TodoSheet] 신규 등록 모드');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDataForEdit(int todoId) async {
    final db = LocalDatabaseSingleton.instance;
    final todo = await db.getTodoById(todoId);
    if (todo == null) return;

    print("------------------------------------------------");
    print("📂 [TodoSheet] DB 데이터 조회 결과");
    print("   - Content: ${todo.content}");
    print("   - Date(Full): ${todo.date}"); // 여기에 시간이 포함되어 있는지 확인해야 함
    print("   - TimeMinutes(AlarmFlag): ${todo.timeMinutes}");
    print("   - CategoryId: ${todo.categoryId}");
    print("------------------------------------------------");

    setState(() {
      contentController.text = todo.content;
      _currentDate = todo.date;

      final hasTimeInDate = todo.date.hour != 0 || todo.date.minute != 0;

      final hasAlarmFlag = todo.timeMinutes != null;

      if (hasTimeInDate) {
        selectedTime = TimeOfDay(
          hour: todo.date.hour,
          minute: todo.date.minute,
        );
        print(
          "⏰ [TodoSheet] 시간 복원됨 (Date 기준): ${selectedTime!.format(context)}",
        );
      } else if (hasAlarmFlag) {
        // 시간은 00:00이지만 알람 플래그가 있다면 00:00으로 설정
        selectedTime = TimeOfDay(hour: 0, minute: 0);
        print("⏰ [TodoSheet] 시간 복원됨 (00:00 / 알람 플래그 기준)");
      } else {
        selectedTime = null;
        print("zzz [TodoSheet] 시간 없음 (null 설정)");
      }

      isChecked = hasAlarmFlag;
      print("🔔 [TodoSheet] 알람 스위치: $isChecked");

      if (todo.categoryId != null) {
        // 현재 로드된 카테고리 리스트(todos)에 해당 ID가 있는지 검사
        final matchIndex = todos.indexWhere((cat) => cat.id == todo.categoryId);

        if (matchIndex != -1) {
          selectedCategoryId = todo.categoryId;
          print(
            "🏷️ [TodoSheet] 카테고리 매칭 성공: ${todos[matchIndex].categoryName} (ID: ${todo.categoryId})",
          );
        } else {
          // 리스트엔 없지만 DB엔 ID가 있는 경우 (강제 할당)
          selectedCategoryId = todo.categoryId;
          print(
            "⚠️ [TodoSheet] 카테고리 매칭 경고: 리스트에 ID ${todo.categoryId}가 없으나 값은 설정함.",
          );
        }
      } else {
        print("⚪ [TodoSheet] 이 투두는 카테고리가 없음 (NULL)");
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
        // [확인용 로그] 이 로그가 콘솔에 떠야 수정이 잘 된 것입니다!
        print("💾 [Save] 저장 버튼 클릭됨 (수정된 코드 실행중)");
        print("   👉 현재 UI에 설정된 시간: ${selectedTime?.hour ?? '없음'}시 ${selectedTime?.minute ?? '없음'}분");
        print("   👉 현재 UI에 선택된 카테고리ID: $selectedCategoryId");

        // 1. 유효성 검사
        if (contentController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("내용을 입력해주세요")));
          return;
        }
        if (isChecked && selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("알람을 켜려면 '시간 선택'은 필수입니다.")));
          return;
        }

        try {
          setState(() => _isLoading = true);

          // ---------------------------------------------------------
          // [STEP 1] 카테고리 ID 강제 확정 (NULL 방지 로직)
          // ---------------------------------------------------------
          int finalLocalCategoryId; // 로컬 DB 저장용 ID
          int realServerId;         // 서버 전송용 ID
          int colorIndex = 0;

          if (selectedCategoryId != null) {
            // 사용자가 선택한 경우
            finalLocalCategoryId = selectedCategoryId!;
            try {
              final localCategory = todos.firstWhere((c) => c.id == selectedCategoryId);
              colorIndex = ColorTypeExtension.fromString(localCategory.colorType ?? 'pinkLight').index;
              realServerId = finalLocalCategoryId;
            } catch (e) {
              realServerId = finalLocalCategoryId;
            }
          } else {
            // 사용자가 선택 안 한 경우 -> '기본값' 자동 할당
            print("⚠️ 카테고리 미선택 -> 기본값 자동 할당 시도");
            CategoryItem? defaultCat;
            try {
              // 1순위: black 색상 / 2순위: 첫번째 카테고리
              defaultCat = todos.firstWhere((c) => c.colorType == 'black' || c.colorType == 'uncategorizedBlack',
                  orElse: () => todos.isNotEmpty ? todos.first : throw Exception('카테고리 없음'));
            } catch (_) {}

            if (defaultCat != null) {
              finalLocalCategoryId = defaultCat.id;
              print("   👉 기본 카테고리 ID 할당: $finalLocalCategoryId");
              try {
                colorIndex = ColorTypeExtension.fromString(defaultCat.colorType ?? 'black').index;
              } catch (_) {}
              realServerId = 1;
            } else {
              // 최후의 수단
              finalLocalCategoryId = 0;
              realServerId = 1;
            }
          }

          // ---------------------------------------------------------
          // [STEP 2] 시간 및 날짜 확정 (분 단위 유지)
          // ---------------------------------------------------------
          final String dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
          String? timeStr;

          DateTime fullTodoDate;
          if (selectedTime != null) {
            fullTodoDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, selectedTime!.hour, selectedTime!.minute);
            timeStr = DateFormat('HH:mm').format(fullTodoDate);
          } else {
            fullTodoDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
          }

          // DB에 저장할 분(Minute) 값 계산
          // 알람이 켜져있으면 (시*60 + 분) 저장, 꺼져있으면 NULL
          int? dbTimeMinutes;
          if (isChecked && selectedTime != null) {
            dbTimeMinutes = selectedTime!.hour * 60 + selectedTime!.minute;
          } else {
            dbTimeMinutes = null;
          }

          print("📝 [DB Insert 정보] ID: $finalLocalCategoryId, Time: $fullTodoDate ($dbTimeMinutes)");

          // ---------------------------------------------------------
          // [STEP 3] 서버 및 로컬 저장 실행
          // ---------------------------------------------------------
          final todoService = TodoService();
          if (widget.todoIdToEdit == null) {
            await todoService.registerTodo(
              categoryId: realServerId,
              time: timeStr,
              alarm: isChecked,
              content: contentController.text,
              date: dateStr,
            );
          }

          final db = LocalDatabaseSingleton.instance;

          if (widget.todoIdToEdit != null) {
            await db.updateTodo(
              TodosCompanion(
                id: drift.Value(widget.todoIdToEdit!),
                content: drift.Value(contentController.text),
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(finalLocalCategoryId), // 👈 수정된 ID 사용
                timeMinutes: drift.Value(dbTimeMinutes),       // 👈 수정된 시간 사용
                date: drift.Value(fullTodoDate),
              ),
            );
          } else {
            final newId = await db.insertTodo(
              TodosCompanion.insert(
                content: contentController.text,
                colorType: drift.Value(colorIndex),
                categoryId: drift.Value(finalLocalCategoryId), // 👈 수정된 ID 사용
                scheduleType: drift.Value('TO_DO'),
                timeMinutes: drift.Value(dbTimeMinutes),       // 👈 수정된 시간 사용
                isDone: drift.Value(false),
                date: fullTodoDate,
              ),
            );
            if (isChecked) await _registerNotification(newId, fullTodoDate);
          }

          // 수정 시 알림 갱신
          if (widget.todoIdToEdit != null) {
            await NotificationService().cancelNotification(widget.todoIdToEdit!);
            if (isChecked) await _registerNotification(widget.todoIdToEdit!, fullTodoDate);
          }

          if (widget.onTodoAdded != null) await widget.onTodoAdded!();
          if (widget.onDataChanged != null) await widget.onDataChanged!();

          if (mounted) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 완료!")));

        } catch (e) {
          print("❌ 저장 에러: $e");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
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
          child: _isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : Text('저장하기', style: TextStyle(fontSize: 20, fontFamily: 'PretendardBold', color: Colors.white)),
        ),
      ),
    );
  }

  // (참고) 알림 등록 함수
  Future<void> _registerNotification(int id, DateTime time) async {
    if (time.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: id,
        title: '오늘의 할 일!',
        body: contentController.text,
        scheduledTime: time,
        payload: 'todo_$id',
      );
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
