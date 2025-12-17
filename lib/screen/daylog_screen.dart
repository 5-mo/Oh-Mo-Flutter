import 'dart:math';
import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/component/routine_bottom_sheet.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';
import 'package:ohmo/models/routine.dart';
import 'package:ohmo/services/day_log_service.dart';
import '../customize_category.dart';
import '../models/todo.dart';
import '../db/drift_database.dart' as db;
import 'home_screen.dart';
import 'package:ohmo/db/local_category_repository.dart';
import 'package:ohmo/models/category_item.dart';

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
  String? answer = '';
  String? diary = '';

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

  List<Routine> weeklyRoutines = [];

  late LocalCategoryRepository _repository;
  List<DayLogQuestionItem> _dbQuestions = [];

  Map<String, String> _dailyAnswers = {};

  final FocusNode _answerFocusNode = FocusNode();
  final FocusNode _diaryFocusNode = FocusNode();

  String? _getSelectedEmotion() {
    if (_happyActive) return 'happy';
    if (_sosoActive) return 'soso';
    if (_badActive) return 'bad';
    return null;
  }

  void _setSelectedEmotion(String? emotion) {
    setState(() {
      _happyActive = emotion == 'happy';
      _sosoActive = emotion == 'soso';
      _badActive = emotion == 'bad';
    });
  }

  @override
  void initState() {
    super.initState();

    _focusedDay = widget.selectedDateNotifier.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      logWeeklyData(_focusedDay);
    });

    _answerController = TextEditingController();
    _diaryController = TextEditingController();

    routines = widget.routines;
    todos = widget.todos;

    _filterTodosForSelectedDate();

    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();
    _loadQuestionDeletionStatus();
    _loadDiaryDeletionStatus();

    final database = db.LocalDatabaseSingleton.instance;
    _repository = LocalCategoryRepository(database);

    _loadAndInitializeQuestions();

    _loadDayLogData(_focusedDay);

    _answerFocusNode.addListener(_onAnswerFocusChange);
    _diaryFocusNode.addListener(_onDiaryFocusChange);

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
          builder: (_) => TodoBottomSheet(selectedDate: _focusedDay),
        );
      });
    }
    widget.selectedDateNotifier.addListener(() {
      if (!mounted) return;
      if (_focusedDay != widget.selectedDateNotifier.value) {
        _updateFocusedDay(widget.selectedDateNotifier.value);
      }
    });
  }

  Future<void> _loadAndInitializeQuestions() async {
    List<DayLogQuestionItem> currentLocalQuestions =
        await _repository.fetchDayLogQuestions();

    final Set<String> existingContents =
        currentLocalQuestions.map((q) => q.question.trim()).toSet();

    final List<Map<String, String>> defaultQuestions = [
      {'emoji': '💰', 'text': '오늘의 소비는?'},
      {'emoji': '😊', 'text': '오늘의 내가 감사했던 일은?'},
    ];

    for (var defaultQ in defaultQuestions) {
      final String content = defaultQ['text']!.trim();
      final String emoji = defaultQ['emoji']!;

      if (!existingContents.contains(content)) {
        await _repository.insertDayLogQuestion(content, emoji);
        existingContents.add(content);
      }
    }
    final dayLogService = DayLogService();
    final serverQuestions = await dayLogService.getQuestions();

    if (serverQuestions != null && serverQuestions.isNotEmpty) {
      for (var serverQ in serverQuestions) {
        final String content = (serverQ['questionContent'] ?? '').trim();
        final String emoji = serverQ['emoji'] ?? '';
        if (content.isNotEmpty && !existingContents.contains(content)) {
          await _repository.insertDayLogQuestion(content, emoji);
          existingContents.add(content);
        }
      }
    }

    List<DayLogQuestionItem> allFetchedDaylogs =
        await _repository.fetchDayLogQuestions();

    final Set<String> seenQuestions = {};
    final List<DayLogQuestionItem> uniqueDaylogs = [];

    for (var question in allFetchedDaylogs) {
      final trimmedText = question.question.trim();
      if (!seenQuestions.contains(trimmedText)) {
        seenQuestions.add(trimmedText);
        uniqueDaylogs.add(question);
      }
    }

    if (mounted) {
      setState(() {
        _dbQuestions = uniqueDaylogs;
      });
    }
  }

  Future<void> _insertDefaultQuestions() async {
    final defaultQuestions = [
      {'emoji': '💰', 'text': '오늘의 소비는?'},
      {'emoji': '😊', 'text': '오늘의 내가 감사했던 일은?'},
    ];
    final database = db.LocalDatabaseSingleton.instance;

    for (var item in defaultQuestions) {
      await database
          .into(database.dayLogQuestions)
          .insert(
            db.DayLogQuestionsCompanion(
              question: Value(item['text']!),
              emoji: Value(item['emoji']!),
            ),
          );
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _diaryController.dispose();

    _answerFocusNode.removeListener(_onAnswerFocusChange);
    _diaryFocusNode.removeListener(_onDiaryFocusChange);

    _answerFocusNode.dispose();
    _diaryFocusNode.dispose();

    super.dispose();
  }

  void _onAnswerFocusChange() {
    if (!_answerFocusNode.hasFocus) {
      if (selectedQuestion != null) {
        _dailyAnswers[selectedQuestion!] = _answerController.text;
      }
      _saveDaylogData(showSnackbar: false);
    }
  }

  void _onDiaryFocusChange() {
    if (!_diaryFocusNode.hasFocus) {
      _saveDaylogData(showSnackbar: false);
    }
  }

  @override
  void didUpdateWidget(DaylogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routines != oldWidget.routines ||
        widget.todos != oldWidget.todos ||
        widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        routines = widget.routines;
        todos = widget.todos;
        _filterTodosForSelectedDate();
      });
      logWeeklyData(_focusedDay);
    }
  }

  void _filterTodosForSelectedDate() {
    filteredTodos =
        todos.where((todo) {
          final isCompleted = todo.isDone;
          final isOnSelectedDay =
              todo.Date.year == _focusedDay.year &&
              todo.Date.month == _focusedDay.month &&
              todo.Date.day == _focusedDay.day;
          return isCompleted && isOnSelectedDay;
        }).toList();
  }

  Future<void> _loadDayLogData(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final dateOnly = DateTime(date.year, date.month, date.day);
    final existingLog = await database.getDayLog(dateOnly);

    if (existingLog != null) {
      _diaryController.text = existingLog.diary ?? '';
      _setSelectedEmotion(existingLog.emotion);

      if (existingLog.answerMapJson != null) {
        try {
          _dailyAnswers = Map<String, String>.from(
            jsonDecode(existingLog.answerMapJson!),
          );
        } catch (e) {
          _dailyAnswers = {};
        }
      } else {
        _dailyAnswers = {};
      }

      setState(() {
        selectedQuestion = null;
        _answerController.clear();
      });
    } else {
      _diaryController.clear();
      _dailyAnswers = {};
      _answerController.clear();
      setState(() {
        selectedQuestion = null;
        _resetIconState();
      });
    }
  }

  Future<void> _updateFocusedDay(DateTime newDate) async {
    setState(() {
      _focusedDay = newDate;
      if (widget.selectedDateNotifier.value != newDate) {
        widget.selectedDateNotifier.value = newDate;
      }
    });

    _filterTodosForSelectedDate();
    await logWeeklyData(newDate);
    await _loadDayLogData(newDate);
  }

  Future<void> logWeeklyData(DateTime date) async {
    final localDate = date.toLocal();
    final weekday = localDate.weekday;

    final mondayOfThisWeek = localDate.subtract(Duration(days: weekday - 1));

    List<Routine> fetchedWeeklyRoutines = [];

    for (int i = 0; i < 7; i++) {
      final currentDate = mondayOfThisWeek.add(Duration(days: i));

      final dailyRoutines = await fetchRoutines(currentDate);

      final visibleRoutines =
          dailyRoutines
              .where((r) => isRoutineVisibleOnDate(r, currentDate))
              .toList();

      fetchedWeeklyRoutines.addAll(visibleRoutines);
    }

    if (mounted) {
      setState(() {
        weeklyRoutines = fetchedWeeklyRoutines;
      });
    }
  }

  List<Map<String, int>> countRoutines(List<String> routines) {
    final Map<String, int> counter = {};
    for (var r in routines) {
      counter[r] = (counter[r] ?? 0) + 1;
    }
    return counter.entries.map((e) => {e.key: e.value}).toList();
  }

  bool isRoutineVisibleOnDate(Routine routine, DateTime selectedDate) {
    final localDate = selectedDate.toLocal();

    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

    final routineStartLocal = routine.startDate!.toLocal();
    final start = DateTime(
      routineStartLocal.year,
      routineStartLocal.month,
      routineStartLocal.day,
    );

    final routineEndLocal = routine.endDate.toLocal();
    final end = DateTime(
      routineEndLocal.year,
      routineEndLocal.month,
      routineEndLocal.day,
    );

    final isVisible =
        !dateOnly.isBefore(start) &&
        !dateOnly.isAfter(end) &&
        routine.daysOfWeek.contains(dateOnly.weekday);

    if (routine.isDone) {
      return true;
    }
    return isVisible;
  }

  Future<List<Routine>> fetchRoutines(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final allRoutines = await database.getAllRoutines();
    final completedIds = await database.getCompletedRoutineIds(date);

    return allRoutines.map((r) {
      return Routine(
        id: r.id,
        content: r.content,
        colorType: ColorType.values[r.colorType],
        isDone: completedIds.contains(r.id),
        startDate: r.startDate ?? DateTime.now(),
        endDate: r.endDate ?? DateTime.now(),
        daysOfWeek: parseWeekDays(r.weekDays),
        time: convertMinutesToTime(r.timeMinutes),
        alarm: false,
      );
    }).toList();
  }

  Future<List<Todo>> fetchTodos(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getAllTodos();
    return fetched.map((t) {
      return Todo(
        id: t.id,
        content: t.content,
        Date: t.date,
        colorType: ColorType.values[t.colorType],
        isDone: t.isDone,
        alarm: false,
      );
    }).toList();
  }

  List<int> parseWeekDays(String? weekDaysStr) {
    if (weekDaysStr == null || weekDaysStr.isEmpty) return [];

    const dayMap = {
      'MONDAY': 1,
      'TUESDAY': 2,
      'WEDNESDAY': 3,
      'THURSDAY': 4,
      'FRIDAY': 5,
      'SATURDAY': 6,
      'SUNDAY': 7,
    };

    try {
      return weekDaysStr
          .split(',')
          .map((e) {
            final trimmed = e.trim();
            final asInt = int.tryParse(trimmed);
            if (asInt != null) {
              return asInt;
            }
            return dayMap[trimmed.toUpperCase()] ?? 0;
          })
          .where((e) => e != 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  String? convertMinutesToTime(int? minutes) {
    if (minutes == null) return null;
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
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

  void _onLeftChevronPressed() async {
    await _updateFocusedDay(_focusedDay.subtract(Duration(days: 1)));
  }

  void _onRightChevronPressed() async {
    await _updateFocusedDay(_focusedDay.add(Duration(days: 1)));
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

    _saveDaylogData(showSnackbar: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                if (!_hideRoutineUI) _buildRoutineBanner(),
                if (!_hideTodoUI) SizedBox(height: 13),
                if (!_hideRoutineUI) _buildRoutineSection(),
                if (!_hideTodoUI) SizedBox(height: 15),
                if (!_hideTodoUI) _buildDoneBanner(),
                if (!_hideTodoUI) _buildDoneSection(),
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
    final Map<String, List<Routine>> groupedRoutines = {};

    for (var routine in weeklyRoutines) {
      if (groupedRoutines.containsKey(routine.content)) {
        groupedRoutines[routine.content]!.add(routine);
      } else {
        groupedRoutines[routine.content] = [routine];
      }
    }
    final todaysRoutineEntries =
        groupedRoutines.entries.where((entry) {
          return entry.value.any(
            (routineInstance) =>
                isRoutineVisibleOnDate(routineInstance, _focusedDay),
          );
        }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 33.0),
      child: Column(
        children: [
          if (todaysRoutineEntries.isEmpty) ...[
            SizedBox(height: 5),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  todaysRoutineEntries.map((entry) {
                    final routineContent = entry.key;
                    final routineInstances = groupedRoutines[routineContent]!;

                    final totalCount = routineInstances.length;
                    final completedCount =
                        routineInstances.where((r) => r.isDone).length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            " • ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              routineContent,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'PretendardRegular',
                              ),
                            ),
                          ),
                          SizedBox(width: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              totalCount,
                              (index) => Container(
                                width: 20,
                                height: 4,
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color:
                                      index < completedCount
                                          ? Colors.black
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Container(
                            width: 40,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "$completedCount/$totalCount",
                              style: TextStyle(
                                fontFamily: 'RubikSprayPaint',
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 320, child: Divider(color: Colors.grey)),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 33.0, vertical: 15.0),
      child: Column(
        children: [
          if (filteredTodos.isEmpty) ...[
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
          ] else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredTodos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                childAspectRatio: 6 / 1,
              ),
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " • ",
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 320, child: Divider(color: Colors.grey)),
            ],
          ),
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
          builder: (_) => TodoBottomSheet(selectedDate: _focusedDay),
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

  Future<Map<int, double>> _calculateMonthlyProgress() async {
    final database = db.LocalDatabaseSingleton.instance;
    final allTodosFromDb = await database.getAllTodos();

    final Map<int, double> progressMap = {};
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final todosForDay =
          allTodosFromDb.where((todo) {
            return todo.date.year == year &&
                todo.date.month == month &&
                todo.date.day == day;
          }).toList();

      if (todosForDay.isEmpty) {
        progressMap[day] = -1.0;
      } else {
        final completedCount = todosForDay.where((todo) => todo.isDone).length;
        final totalCount = todosForDay.length;
        final percentage = (completedCount / totalCount) * 100.0;
        progressMap[day] = percentage;
      }
    }
    return progressMap;
  }

  Color _getColorForPercentage(double? percentage) {
    if (percentage == null || percentage <= 20) {
      return Colors.white;
    } else if (percentage < 60) {
      return Colors.grey[300]!;
    } else if (percentage < 80) {
      return Colors.grey[500]!;
    } else if (percentage < 100) {
      return Colors.grey[700]!;
    } else {
      return Colors.black;
    }
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 40.0),
      child: FutureBuilder<Map<int, double>>(
        future: _calculateMonthlyProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('진행률을 불러오는 데 실패했습니다.'));
          }
          if (snapshot.hasData) {
            final progressMap = snapshot.data!;
            final bool hasTodosThisMonth = progressMap.values.any(
              (progress) => progress >= 0,
            );

            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
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
                    itemCount: progressMap.length,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final percentage = progressMap[day];
                      final color = _getColorForPercentage(percentage);

                      return Container(
                        decoration: BoxDecoration(
                          color: color,
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
                if (!hasTodosThisMonth)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "이번 달 to-do 달성률을 보여드립니다.\n퍼센트에 따라 색깔을 달리 표현합니다.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'PretendardSemiBold',
                              color: DARK_GREY_COLOR,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildCalendarButton(),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCalendarButton() {
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
          child: Text(
            '캘린더 보러 가기',
            style: TextStyle(fontSize: 10, fontFamily: 'PretendardRegular'),
          ),
        ),
      ),
    );
  }

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
    final allQuestionStrings =
        _dbQuestions.map((q) {
          if (q.emoji.isNotEmpty) {
            return '${q.emoji} ${q.question}';
          }
          return q.question;
        }).toList();
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children:
                allQuestionStrings.map((questionText) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildQuestionButton(questionText),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionButton(String text) {
    bool isSelected = selectedQuestion == text;

    return GestureDetector(
      onTap: () {
        if (selectedQuestion != null) {
          _dailyAnswers[selectedQuestion!] = _answerController.text;
        }

        setState(() {
          selectedQuestion = (selectedQuestion == text) ? null : text;
        });
        if (selectedQuestion != null) {
          _answerController.text = _dailyAnswers[selectedQuestion!] ?? '';
        } else {
          _answerController.clear();
        }
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
                      focusNode: _answerFocusNode,
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
          focusNode: _diaryFocusNode,
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

  void _saveDaylogData({bool showSnackbar = true}) async {
    final database = db.LocalDatabaseSingleton.instance;
    final dateOnly = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );

    if (selectedQuestion != null && _answerFocusNode.hasFocus) {
      _dailyAnswers[selectedQuestion!] = _answerController.text;
    }

    final String? answerMapString =
        _dailyAnswers.isEmpty ? null : jsonEncode(_dailyAnswers);

    final entry = db.DayLogsCompanion(
      date: Value(dateOnly),
      emotion: Value(_getSelectedEmotion()),
      diary: Value(_diaryController.text),
      answerMapJson: Value(answerMapString),
    );

    await database.upsertDayLog(entry);

    if (mounted && showSnackbar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('데이로그가 저장되었습니다.')));
    }
  }

  Widget _buildDaylogSaveButton() {
    return GestureDetector(
      onTap: () => _saveDaylogData(showSnackbar: true),
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
