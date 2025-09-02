import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/component/routine_bottom_sheet.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';
import 'package:ohmo/models/routine.dart';
import 'package:ohmo/shared_data.dart';
import 'package:ohmo/temporary_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../customize_category.dart';
import '../models/CompletedRoutine.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class DaylogScreen extends StatefulWidget {
  final String? date;
  final Function(int) onTabChange;
  final ValueNotifier<DateTime> selectedDateNotifier;
  final bool showTodoSheet;
  final DateTime selectedDate;
  final List<Routine> routines;
  final List<Todo> todos;

  DaylogScreen({
    required this.onTabChange,
    this.date,
    required this.selectedDateNotifier,
    this.showTodoSheet = false,
    required this.selectedDate,
    required this.routines,
    required this.todos,
  });

  @override
  _DaylogScreenState createState() => _DaylogScreenState();
}

class _DaylogScreenState extends State<DaylogScreen> {
  bool isPressed = false;
  String? selectedQuestion;
  String? answer='';
  String? diary='';

  late DateTime _focusedDay;
  bool _happyActive = false;
  bool _sosoActive = false;
  bool _badActive = false;

  late List<Routine> routines;
  late List<Todo> todos;
  List<Routine> filteredRoutines = [];
  List<Todo> filteredTodos = [];

  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;
  bool _hideQuestionUI = false;
  bool _hideDiaryUI = false;

  late TextEditingController _answerController;
  late TextEditingController _diaryController;

  @override
  void initState() {
    super.initState();

    _focusedDay = widget.selectedDateNotifier.value;


    _answerController = TextEditingController();
    _diaryController = TextEditingController();

    _loadSavedData();

    routines = widget.routines;
    todos = widget.todos;

    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();
    _loadQuestionDeletionStatus();
    _loadDiaryDeletionStatus();

    _filterRoutinesByDate(_focusedDay);

    if (widget.showTodoSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
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
          builder: (_) => TodoBottomSheet(selectedDate: widget.selectedDate),
        );
      });
    }
    widget.selectedDateNotifier.addListener(() {
      if (!mounted) return;
      if (_focusedDay != widget.selectedDateNotifier.value) {
        setState(() {
          _focusedDay = widget.selectedDateNotifier.value;
          _filterRoutinesByDate(_focusedDay);
        });
      }
    });
    _loadRoutines();
    _loadTodos();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_focusedDay);
    final loadedAnswer = await LocalStorage.loadAnswer(dateStr);
    final loadedDiary = await LocalStorage.loadDiary(dateStr);

    setState(() {
      answer = loadedAnswer;
      diary = loadedDiary;
      _answerController.text = answer!;
      _diaryController.text = diary!;
    });
  }

  void _saveData() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_focusedDay);
    await LocalStorage.saveAnswer(dateStr, _answerController.text);
    await LocalStorage.saveDiary(dateStr, _diaryController.text);
  }


  Future<void> _loadRoutineDeletionStatus() async {
    final visible = await RoutineVisibilityHelper.getVisibility();
    if (!mounted) return;
    setState(() {
      _hideRoutineUI = !visible;
    });
  }

  Future<void> _loadTodoDeletionStatus() async {
    final visible = await TodoVisibilityHelper.getVisibility();
    if (!mounted) return;
    setState(() {
      _hideTodoUI = !visible;
    });
  }

  Future<void> _loadQuestionDeletionStatus() async {
    final visible = await QuestionVisibilityHelper.getVisibility();
    if (!mounted) return;
    setState(() {
      _hideQuestionUI = !visible;
    });
  }

  Future<void> _loadDiaryDeletionStatus() async {
    final visible = await DiaryVisibilityHelper.getVisibility();
    if (!mounted) return;
    setState(() {
      _hideDiaryUI = !visible;
    });
  }

  Future<void> _loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    // ✅ 주차 범위 계산
    final now = _focusedDay;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));


    setState(() {
      _filterRoutinesByDate(_focusedDay); // 당일 필터링은 유지
    });
  }

  void _filterRoutinesByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    filteredRoutines =
        routines.where((routine) {
          final startOnly = DateTime(
            routine.endDate.year,
            routine.endDate.month,
            routine.endDate.day,
          );
          final endOnly = DateTime(
            routine.endDate.year,
            routine.endDate.month,
            routine.endDate.day,
          );
          final isInRange =
              !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
          final isOnWeekday = routine.daysOfWeek.contains(dateOnly.weekday);

          return isInRange && isOnWeekday;
        }).toList();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final service = TodoService();
    final result = await service.getTodos(_focusedDay, token);

    setState(() {
      todos = result;
      _filterTodosByDate(_focusedDay);
    });
  }

  void _filterTodosByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    filteredTodos =
        todos.where((todo) {
          final todoDateOnly = DateTime(
            todo.Date.year,
            todo.Date.month,
            todo.Date.day,
          );
          return todoDateOnly == dateOnly && todo.isDone == true;
        }).toList();
  }

  void _onLeftChevronPressed() async {
    setState(() {
      _focusedDay = _focusedDay.subtract(Duration(days: 1));
      _resetIconState();
    });
    await _loadRoutines();
    await _loadTodos();
    await _loadSavedData();
  }

  void _onRightChevronPressed() async {
    setState(() async {
      _focusedDay = _focusedDay.add(Duration(days: 1));
      _resetIconState();
      await _loadSavedData();
    });
    await _loadRoutines();
    await _loadTodos();
  }

  void _resetIconState() {
    _happyActive = false;
    _sosoActive = false;
    _badActive = false;
  }

  void _onIconPressed(String iconName) {
    setState(() {
      if (iconName == 'happy_unselected') {
        _happyActive = !_happyActive;
        _sosoActive = false;
        _badActive = false;
      } else if (iconName == 'soso_unselected') {
        _sosoActive = !_sosoActive;
        _happyActive = false;
        _badActive = false;
      } else if (iconName == 'bad_unselected') {
        _badActive = !_badActive;
        _happyActive = false;
        _sosoActive = false;
      }
    });
  }

  void updateRoutineProgress(
    List<Routine> routines,
    List<CompletedRoutine> completedRoutineList,
  ) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    for (var routine in routines) {
      int total = 0;
      int done = 0;

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        if (routine.daysOfWeek.contains(date.weekday)) {
          total++;

          final isCompleted = completedRoutineList.any(
            (completed) =>
                completed.routineId == routine.id &&
                completed.date.year == date.year &&
                completed.date.month == date.month &&
                completed.date.day == date.day,
          );

          if (isCompleted) {
            done++;
          }
        }
      }

      routine.totalDaysThisWeek = total;
      routine.completedDays = done;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 내리기
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                if (!_hideRoutineUI) _buildRoutineBanner(),
                if (!_hideRoutineUI) _buildRoutineSection(),
                if (!_hideTodoUI) SizedBox(height: 30),
                if (!_hideTodoUI) _buildDoneBanner(),
                if (!_hideTodoUI) _buildDoneSection(),
                if (!_hideTodoUI) SizedBox(height: 30),
                if (!_hideTodoUI) _buildProgressBanner(),
                if (!_hideTodoUI) SizedBox(height: 20),
                if (!_hideTodoUI) _buildProgressSection(),
                if (!_hideQuestionUI) SizedBox(height: 20),
                if (!_hideQuestionUI) _buildQuestionBanner(),
                if (!_hideQuestionUI) _buildQuestionButtons(),
                if (selectedQuestion != null)
                  if (!_hideQuestionUI) _buildAnswerField(selectedQuestion!),
                if (!_hideDiaryUI) SizedBox(height: 30),
                if (!_hideDiaryUI) _buildDiaryBanner(),
                if (!_hideDiaryUI) _buildDiaryField(),
                SizedBox(height: 20),
                _buildDaylogSaveButton(),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _onLeftChevronPressed,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(40, 15),
                child: Text(
                  DateFormat('MMM').format(_focusedDay).toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(40, 5),
                child: Text(
                  DateFormat('dd').format(_focusedDay),
                  style: TextStyle(
                    fontSize: 45.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(40, -5),
                child: Text(
                  DateFormat('E').format(_focusedDay).toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'RubikSprayPaint',
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('happy_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/happy_unselected.svg',
                    color: _happyActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('soso_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/soso_unselected.svg',
                    color: _sosoActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-20, 0),
                child: GestureDetector(
                  onTap: () => _onIconPressed('bad_unselected'),
                  child: SvgPicture.asset(
                    'android/assets/images/bad_unselected.svg',
                    color: _badActive ? Colors.black : Colors.grey,
                    height: 35.0,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _onRightChevronPressed,
            icon: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineBanner() {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Routine', style: textStyle),
          Transform.translate(offset: Offset(5, 0)),
        ],
      ),
    );
  }

  Widget _buildRoutineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        children: [
          if (routines.isEmpty) ...[
            Center(
              child: Text(
                "이번 주 루틴 현황을 보여드립니다.",
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'PretendardSemiBold',
                  color: DARK_GREY_COLOR,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(child: _buildRoutineButton()),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 320, child: Divider(color: Colors.grey)),
              ],
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredRoutines.length,
              itemBuilder: (context, index) {
                final routine = filteredRoutines[index];
                print(
                  "DaylogScreen initState routines length: ${routines.length}",
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3.0,
                    horizontal: 5.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          "      •",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            routine.content,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PretendardRegular',
                            ),
                          ),
                        ),

                        Container(
                          width: 60,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.grey[300],
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                routine.daysOfWeek.isEmpty
                                    ? 0.0
                                    : routine.completedDays /
                                        routine.daysOfWeek.length,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "${routine.completedDays}/${routine.totalDaysThisWeek}",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'RubikSprayPaint',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
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
          builder: (_) => RoutineBottomSheet(),
        );
      },
      child: Container(
        width: 87,
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
              '루틴 만들기',
              style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneBanner() {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Done", style: textStyle),
            Transform.translate(offset: Offset(5, 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Column(
        children: [
          if (todos.isEmpty) ...[
            Center(
              child: Text(
                "오늘 끝낸 to-do 리스트를 보여드립니다.",
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'PretendardSemiBold',
                  color: DARK_GREY_COLOR,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(child: _buildTodoButton()),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 320, child: Divider(color: Colors.grey)),
              ],
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                print("DaylogScreen initState todos length: ${todos.length}");
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3.0,
                    horizontal: 5.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          "      •",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            todo.content,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PretendardRegular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
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
          builder: (_) => TodoBottomSheet(selectedDate: widget.selectedDate),
        );
      },
      child: Container(
        width: 87,
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
              '투두 만들기',
              style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBanner() {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Monthly Progress", style: textStyle),
            Transform.translate(offset: Offset(5, 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    int daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

    // 랜덤으로 칠할 사각형 개수
    int blackSquaresCount = 5; // 예: 5개

    int seed = int.parse(DateFormat('yyyyMMdd').format(_focusedDay));
    final random = Random(seed);
    final blackIndices = <int>{};
    while (blackIndices.length < blackSquaresCount) {
      blackIndices.add(random.nextInt(daysInMonth));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 40.0),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 11,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 1.0,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final isBlack = blackIndices.contains(index);
            return Container(
              decoration: BoxDecoration(
                color: isBlack ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
            );
          },
        ),
      ),
    );
  }

  /*Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      },
      child: Container(
        width: 87,
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
              '캘린더 보러 가기',
              style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
            ),
          ),
        ),
      ),
    );
  }

   */

  Widget _buildQuestionBanner() {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question', style: textStyle),
            Transform.translate(offset: Offset(5, 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            ...daylogQuestions.map(
              (q) => Row(children: [_buildQuestionButton(q.content)]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionButton(String text) {
    bool isSelected = selectedQuestion == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuestion = (selectedQuestion == text) ? null : text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isSelected ? DARK_GREY_COLOR : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'PretendardRegular',
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerField(String question) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            question,
            style: TextStyle(fontSize: 13, fontFamily: 'PretendardSemibold'),
          ),
          SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                Container(
                  width: 300,
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
                      controller: _answerController,
                      decoration: InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          answer = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryBanner() {
    final textStyle = TextStyle(fontFamily: 'RubikSprayPaint', fontSize: 16.0);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Today was...', style: textStyle)],
        ),
      ),
    );
  }

  Widget _buildDiaryField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: TextField(
          controller: _diaryController,
          maxLines: null,
          minLines: 10,
          decoration: InputDecoration(
            hintText: "오늘은 어떤 하루였나요?",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderSide: BorderSide.none),
            hintStyle: TextStyle(
              fontFamily: 'PretendardRegular',
              color: LIGHT_GREY_COLOR,
              fontSize: 14,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
          ),
          onChanged: (value) {
            setState(() {
              diary = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDaylogSaveButton() {
    return GestureDetector(
      onTap: () {
        _saveData();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이로그가 저장되었습니다.')),
        );
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
            '일기 저장하기',
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
}
