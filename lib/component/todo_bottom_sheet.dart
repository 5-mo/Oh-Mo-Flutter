import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/const/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/category_screen.dart';
import '../services/category_service.dart';
import '../services/todo_service.dart';

class TodoBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Future<void> Function()? onTodoAdded;
  final Future<void> Function()? onDataChanged;
  const TodoBottomSheet({Key? key,required this.selectedDate,this.onTodoAdded,
    this.onDataChanged,}) : super(key: key);

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  bool isChecked = false;
  DateTime get selectedDate => widget.selectedDate;

  List<CategoryItem> todos = [];
  int? selectedCategoryId;
  final TextEditingController contentController = TextEditingController();
  final TodoService _todoService=TodoService();


  @override
  void initState() {
    super.initState();
    _loadCategories();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildDateSection(),
                  SizedBox(height: 16),
                  _buildTodoTimeButton(),
                  SizedBox(height: 16),
                  _buildCategorySelectionSection(),
                  _buildContentInputSection(),
                  SizedBox(height: 20),
                  _buildSaveButton(),
                  SizedBox(height: bottomInset),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "날짜 및 시간",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          _buildAlarmToggleSection(),
        ],
      ),
    );
  }

  Widget _buildAlarmToggleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "알람",
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
              Transform.scale(
                scale: 1,
                child: CupertinoSwitch(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                    print("알람 상태 : $value");
                  },
                  activeColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TimeOfDay? selectedTime;

  Widget _buildTodoTimeButton() {
    String selectedDateStr = DateFormat('M월 d일').format(selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedDateStr,
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardRegular'),
        ),
        GestureDetector(
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

            if (pickedTime != null) {
              setState(() {
                selectedTime = pickedTime;
              });
            }
          },
          child: Container(
            width: 195,
            height: 37,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            child: Center(
              child: Center(
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : '시간 선택',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'PretendardRegular',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelectionSection() {

    final hasCategories = todos.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "카테고리",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          if(!hasCategories)...[
          Center(
            child: Text(
              "투두 카테고리를 설정해볼까요?",
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'PretendardSemiBold',
                color: DARK_GREY_COLOR,
              ),
            ),
          ),
          SizedBox(height: 16),
          ]else...[
            _buildCategoryChoiceChips(),
          SizedBox(height:16),
          ],
          Center(child: _buildCategoryButton()),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryChoiceChips() {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
        todos.map((category) {
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
            print('Invalid color type: $colorString');
          }
          return Padding(
            padding: const EdgeInsets.only(right: 4.0,left: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                setState(() {
                  selectedCategoryId = category.id;
                });
              },
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
            MaterialPageRoute(builder: (context) => CategoryScreen()),
          ).then((_) => _loadCategories());
      },
      child: Container(
        width: 97,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Center(
            child: Text(
              '카테고리 추가하기',
              style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "내용",
            style: TextStyle(fontSize: 16, fontFamily: 'PretendardBold'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 320,
                  height: 41,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      controller: contentController,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () async {
        if (selectedTime == null ||
            contentController.text.isEmpty||
            selectedCategoryId == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("모든 필드를 입력해주세요")));
          return;
        }
        try {
          final success = await _todoService.registerTodo(
            categoryId: selectedCategoryId!,
            time: formatTime(selectedTime!),
            alarm: isChecked,
            content: contentController.text,
            date: "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
          );

          if (success) {await widget.onTodoAdded?.call();

          await widget.onDataChanged?.call();

          Navigator.pop(context, true);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("루틴 등록 완료!")));
          }
        } catch (e) {
          print('투두 등록 중 예외 발생:$e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("서버와 통신 중 오류가 발생했습니다.")));
        }
      },
      child: Container(
        width: 334,
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


    String formatTime(TimeOfDay timeOfDay) {
      final hour = timeOfDay.hour.toString().padLeft(2, '0');
      final minute = timeOfDay.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    void _loadCategories() async {
      try {
        final accessToken = await getAccessToken();
        if (accessToken == null) return;

        final fetched = await CategoryService.fetchCategories(
          scheduleType: 'TO_DO',
          accessToken: accessToken,
        );

        setState(() {
          todos = fetched;
        });
      } catch (e) {
        print('카테고리 로드 실패: $e');
      }
    }

    Future<String?> getAccessToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('accessToken');
    }
}
