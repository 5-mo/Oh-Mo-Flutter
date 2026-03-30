import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohmo/component/invitation_popup.dart';
import 'package:ohmo/component/main_calendar.dart';
import 'package:ohmo/component/todo_bottom_sheet.dart';
import 'package:ohmo/models/monthly_schedule_response.dart';
import 'package:ohmo/models/daily_schedule_response.dart';
import 'package:ohmo/screen/daylog_screen.dart';
import 'package:ohmo/screen/group/group_main_screen.dart';
import 'package:ohmo/screen/home_screen_to_group_screen.dart';
import 'package:ohmo/screen/my_screen.dart';
import 'package:ohmo/component/routine_banner.dart';
import 'package:ohmo/component/routine_card.dart';
import 'package:ohmo/component/todo_banner.dart';
import 'package:ohmo/component/todo_card.dart';
import 'package:ohmo/component/bottom_navigation_bar.dart';
import 'package:ohmo/services/calendar_service.dart';
import 'package:ohmo/services/group_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ohmo/services/widget_updater.dart';
import 'dart:convert';
import '../component/alarm_bottom_sheet.dart';
import '../component/invitation_accept_popup.dart';
import '../component/routine_bottom_sheet.dart';
import '../const/colors.dart';
import '../customize_category.dart';
import '../db/drift_database.dart' as db;
import '../models/profile_data_provider.dart';
import '../models/routine.dart';
import '../models/todo.dart';
import '../services/category_service.dart';
import '../services/notification_service.dart';
import '../services/routine_service.dart';
import '../services/sync_service.dart';
import '../services/todo_service.dart';
import 'notification_screen.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';

bool _isGlobalWidgetSheetOpen = false;

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool showTodoSheetForDaylog;

  const HomeScreen({
    Key? key,
    this.initialTabIndex = 0,
    this.showTodoSheetForDaylog = false,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _selectedIndex;
  Uri? _lastProcessedUri;
  bool _isProcessingWidgetClick = false;
  bool _isWidgetSheetOpen = false;
  bool _hasShownInitialTodoSheet = false;
  final LayerLink _calendarlayerLink = LayerLink();
  final LayerLink _routineLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier(
    DateTime.now(),
  );
  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Todo>> _todosNotifier = ValueNotifier([]);
  final ValueNotifier<Map<DateTime, List<Todo>>> _calendarTodosNotifier =
      ValueNotifier({});
  final CalendarService _calendarService = CalendarService();
  late DateTime _currentFocusedMonth;

  bool _hideRoutineUI = false;
  bool _hideTodoUI = false;
  final Set<int> _shownInvitationIds = {};
  bool _isInvitationDialogShowing = false;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final database = db.LocalDatabaseSingleton.instance;

      final String? serverType = message.data['type'];
      final String groupName = message.data['groupName'] ?? '새로운';
      final String serverMessage = message.data['message'] ?? message.notification?.body ?? '내용 없음';
      final String? serverDateStr = message.data['date'];
      String formattedNoticeDate = "";

      if (serverDateStr != null) {
        try {
          DateTime dt = DateTime.parse(serverDateStr);
          formattedNoticeDate = " (일시 : ${DateFormat('MM/dd').format(dt)})";
        } catch (e) {
          print("날짜 파싱 에러: $e");
        }
      }

      String saveType = 'group';
      String myCustomContent = "";

      switch (serverType) {
        case 'NOTICE':
          saveType = 'group';
          myCustomContent = "‘$groupName’ 그룹에 새로운 공지가 등록되었습니다.\n[공지] $serverMessage$formattedNoticeDate";
          break;

        case 'GROUP_INVITATION':
          saveType = 'invitation';
          myCustomContent = "‘$groupName’ 그룹의 초대장이 도착했습니다.\n초대장을 확인해보세요";
          break;

        case 'SCHEDULE_ADDED':
        case 'ASSIGNEE_ADDED':
          saveType = 'group';
          String serverType = (message.data['scheduleType'] ?? "").toString().toUpperCase();
          String serverMessage = message.data['message'] ?? message.notification?.body ?? "";

          String prefix = "";
          if (serverType == 'ROUTINE' || serverMessage.contains('루틴')) {
            prefix = "[Routine]";
          } else {
            prefix = "[To-do]";
          }

          myCustomContent = "‘$groupName’ 그룹에 새로운 할 일이 등록되었습니다.\n$prefix $serverMessage";
          break;

        default:
          saveType = 'group';
          myCustomContent = message.notification?.body ?? message.data['message'] ?? '새로운 알림이 있습니다.';
      }

      await database.insertNotification(
        db.NotificationsCompanion.insert(
          type: saveType,
          content: myCustomContent,
          timestamp: DateTime.now(),
          isRead: const Value(false),
          relatedId: Value(
            int.tryParse(message.data['invitationId']?.toString() ??
                message.data['groupId']?.toString() ?? '0'),
          ),
        ),
      );


      if (serverType == 'GROUP_INVITATION' && !_isInvitationDialogShowing) {
        _showSingleInvitationPopup(message.data);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialTooltip();
      _checkAndShowInvitations();
    });

    _selectedIndex = widget.initialTabIndex;
    SyncService().monitorNetwork();
    _loadRoutineDeletionStatus();
    _loadTodoDeletionStatus();
    _syncAndCleanCategories();

    WidgetsBinding.instance.addObserver(this);

    final today = DateTime.now();
    _currentFocusedMonth = DateTime(today.year, today.month);

    _initializeData(today);

    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) {
        _handleWidgetClick(uri);
      }
    });

    HomeWidget.widgetClicked.listen((uri) {
      if (uri != _lastProcessedUri) {
        _lastProcessedUri = null;
        _handleWidgetClick(uri);
      }
    });
    WidgetUpdater.update();
  }

  void _showSingleInvitationPopup(Map<String, dynamic> data) async {
    setState(() => _isInvitationDialogShowing = true);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => InvitationPopup(
            invitationId: int.tryParse(data['invitationId'].toString()) ?? 0,
            groupId: int.tryParse(data['groupId'].toString()) ?? 0,
            groupName: data['groupName'] ?? '이름 없음',
          ),
    );
    setState(() => _isInvitationDialogShowing = false);
  }

  Future<void> _checkAndShowInvitations() async {
    final groupService = GroupService();

    List<Map<String, dynamic>> invitations =
        await groupService.fetchMyInvitations();

    for (var invite in invitations) {
      final int invitationId = invite['invitationId'];

      if (_shownInvitationIds.contains(invitationId)) continue;

      if (mounted) {
        _shownInvitationIds.add(invitationId);
        setState(() => _isInvitationDialogShowing = true);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => InvitationPopup(
                invitationId: invite['invitationId'],
                groupId: invite['groupId'],
                groupName: invite['groupName'],
              ),
        );
        if (mounted) {
          setState(() => _isInvitationDialogShowing = false);
        }
      }
    }
  }

  bool _isInitialLoading = true;

  Future<void> _showInitialTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShown = prefs.getBool('hasShownCalendarTooltip') ?? false;

    if (!hasShown && mounted) {
      _showTooltipOverlay();
      await prefs.setBool('hasShownCalendarTooltip', true);
    }
  }

  void _showTooltipOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideToolTip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideFirstAndShowSecond() {
    _hideToolTip();
    _showSecondTooltipOverlay();
  }

  void _showSecondTooltipOverlay() {
    _overlayEntry = _createSecondOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _calendarlayerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(-123, 35),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CustomPaint(
                            size: const Size(8, 10),
                            painter: TrianglePainter(
                              color: const Color(0xFF4E4E4E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E4E4E),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "한 달 / 일주일 보기로\n변경할 수 있어요",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.2,
                                  fontFamily: 'PretendardMedium',
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _hideFirstAndShowSecond,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    "확인",
                                    style: TextStyle(
                                      color: Color(0xFFE6E6E6),
                                      fontSize: 12,
                                      fontFamily: 'PretendardMedium',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  OverlayEntry _createSecondOverlayEntry() {
    return OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _routineLayerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(-232, 35),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CustomPaint(
                            size: const Size(8, 10),
                            painter: TrianglePainter(
                              color: const Color(0xFF4E4E4E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E4E4E),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "+",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'RubikSprayPaint',
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  const Text(
                                    "를 눌러 일정을 등록해보세요!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'PretendardMedium',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: _hideToolTip,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        "확인",
                                        style: TextStyle(
                                          color: Color(0xFFE6E6E6),
                                          fontSize: 12,
                                          fontFamily: 'PretendardMedium',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    if (_isGlobalWidgetSheetOpen || _isProcessingWidgetClick) return;

    if (uri.host == 'daylog' && uri.path == '/todo') {
      _isProcessingWidgetClick = true;
      _isGlobalWidgetSheetOpen = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _hasShownInitialTodoSheet = true;
        });
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(59),
              topLeft: Radius.circular(59),
            ),
          ),
          builder:
              (_) => TodoBottomSheet(
                selectedDate: _selectedDateNotifier.value,
                onTodoAdded: () async {
                  await _loadDataForDate(_selectedDateNotifier.value);
                  await WidgetUpdater.update();
                },
              ),
        ).whenComplete(() {
          _isGlobalWidgetSheetOpen = false;
          _isProcessingWidgetClick = false;
          _lastProcessedUri = null;
        });
      });
    }
  }

  Future<void> _initializeData(DateTime date) async {
    setState(() => _isInitialLoading = true);

    await _fetchMonthlyDataAndRefresh(date);
    await _fetchDailyDataAndRefresh(date);

    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    _hideToolTip();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("앱이 다시 활성화되어 데이터를 새로고침합니다.");
      _loadDataForDate(_selectedDateNotifier.value);
    }
  }

  Future<void> _loadDataForDate(DateTime date) async {
    final routines = await fetchRoutines(date);
    _routinesNotifier.value = routines;

    final todos = await fetchTodos(date);
    _todosNotifier.value = todos;

    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Routine>> fetchRoutines(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final allRoutines = await database.getPersonalRoutines();
    final completedIds = await database.getCompletedRoutineIds(date);

    final mappedRoutines =
        allRoutines.map((r) {
          return Routine(
            id: r.id,
            content: r.content,
            colorType: ColorType.values[r.colorType],
            isDone: completedIds.contains(r.id),
            startDate: r.startDate ?? DateTime(2000, 1, 1),
            endDate: r.endDate ?? DateTime(3000, 12, 31),
            daysOfWeek: parseWeekDays(r.weekDays),
            time: convertMinutesToTime(r.timeMinutes),
            alarm: false,
          );
        }).toList();

    return mappedRoutines;
  }

  Future<List<Todo>> fetchTodos(DateTime date) async {
    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getPersonalTodosByDate(date);

    return fetched.map((t) {
      return Todo(
        id: t.id,
        scheduleId: t.scheduleId,
        todoServerId: t.todoServerId,
        content: t.content,
        Date: t.date,
        colorType: ColorType.values[t.colorType],
        isDone: t.isDone,
        alarm: t.alarmMinutes != null,
      );
    }).toList();
  }

  int? _parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return null;
    }
  }

  String _convertWeekDaysListToString(List<String> repeatWeek) {
    final Map<String, int> dayMap = {
      'MONDAY': 1,
      'TUESDAY': 2,
      'WEDNESDAY': 3,
      'THURSDAY': 4,
      'FRIDAY': 5,
      'SATURDAY': 6,
      'SUNDAY': 7,
    };
    final weekInts =
        repeatWeek
            .map((d) => dayMap[d.toUpperCase().trim()] ?? 0)
            .where((i) => i != 0)
            .toList()
          ..sort();
    return weekInts.join(',');
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

  ColorType _parseColorType(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return ColorType.pinkLight;
    }

    return ColorTypeExtension.fromString(colorString);
  }

  Future<List<int>> loadCompletedTodoIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedTodoIds');
    if (list == null) return [];
    return list.map(int.parse).toList();
  }

  Future<void> _loadRoutineDeletionStatus() async {
    final isVisible = await RoutineVisibilityHelper.getVisibility();
    setState(() => _hideRoutineUI = !isVisible);
  }

  Future<void> _loadTodoDeletionStatus() async {
    final isVisible = await TodoVisibilityHelper.getVisibility();
    setState(() => _hideTodoUI = !isVisible);
  }

  Future<void> _onTabChange(int index) async {
    setState(() => _selectedIndex = index);
    await _loadRoutineDeletionStatus();
    await _loadTodoDeletionStatus();
  }

  Future<void> _loadDataForMonth(DateTime month) async {
    _currentFocusedMonth = DateTime(month.year, month.month, 1);
    final firstDay = _currentFocusedMonth;
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final database = db.LocalDatabaseSingleton.instance;
    final fetched = await database.getTodosBetween(firstDay, lastDay);

    final monthTodos =
        fetched
            .where((t) {
              if (t.isSynced &&
                  (t.todoServerId == null || t.todoServerId == 0)) {
                return false;
              }
              return true;
            })
            .map((t) {
              return Todo(
                id: t.id,
                content: t.content,
                Date: t.date,
                colorType: ColorType.values[t.colorType],
                isDone: t.isDone,
                alarm: false,
              );
            })
            .toList();

    final todoMap = _groupTodosByDay(monthTodos);
    _calendarTodosNotifier.value = todoMap;
  }

  Map<DateTime, List<Todo>> _groupTodosByDay(List<Todo> todos) {
    final Map<DateTime, List<Todo>> map = {};

    for (final todo in todos) {
      if (todo.todoServerId == null || todo.todoServerId == 0) {}

      final day = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);

      if (map[day] == null) {
        map[day] = [];
      }
      map[day]!.add(todo);
    }
    return map;
  }

  void _onDateChanged(DateTime newDate) async {
    _selectedDateNotifier.value = newDate;

    await _loadDataForDate(newDate);

    if (newDate.month != _currentFocusedMonth.month ||
        newDate.year != _currentFocusedMonth.year) {
      _currentFocusedMonth = DateTime(newDate.year, newDate.month);
      await _loadDataForMonth(newDate);
      _fetchMonthlyDataAndRefresh(newDate);
    } else {
      _fetchDailyDataAndRefresh(newDate);
    }
  }

  Future<void> _fetchDailyDataAndRefresh(DateTime date) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final response = await _calendarService.getDailySchedule(dateString);

      if (response.isSuccess && response.result != null) {
        await _syncDailyApiDataToLocalDb(response.result!, date);
        await _loadDataForDate(date);
      }
    } catch (e) {
      print("일별 데이터 동기화 에러 : $e");
    }
  }

  Future<void> _syncApiDataToLocalDb(List<DailyScheduleResult> apiData) async {
    final database = db.LocalDatabaseSingleton.instance;
    final selectedDate = _selectedDateNotifier.value;

    for (var dayData in apiData) {
      final date = DateTime.parse(dayData.date);

      final isSelectedDate =
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      if (isSelectedDate) continue;

      for (var categoryItem in dayData.categoryList) {
        final colorIndex = _parseColorType(categoryItem.color).index;
        final tempContent = categoryItem.categoryName;
        final isRoutine = categoryItem.scheduleType.toUpperCase() == 'ROUTINE';

        if (isRoutine) {
          await (database.delete(database.todos)
            ..where((t) => t.id.equals(categoryItem.id))).go();
        } else {
          final existingTodo =
              await (database.select(database.todos)
                ..where((t) => t.id.equals(categoryItem.id))).getSingleOrNull();

          if (existingTodo != null) continue;

          await database
              .into(database.todos)
              .insert(
                db.TodosCompanion.insert(
                  id: Value(categoryItem.id),
                  groupId: const Value(null),
                  content: tempContent,
                  date: date,
                  colorType: Value(colorIndex),
                  isDone: const Value(false),
                ),
              );
          await (database.delete(database.routines)
            ..where((r) => r.id.equals(categoryItem.id))).go();
        }
      }
    }
  }

  Future<void> _syncAndCleanCategories() async {
    final database = db.LocalDatabaseSingleton.instance;
    final categoryService = CategoryService();

    try {
      final routineCats = await categoryService.getCategories('ROUTINE');
      final todoCats = await categoryService.getCategories('TO_DO');
      final serverCategories = [...routineCats, ...todoCats];

      if (serverCategories.isEmpty) return;

      for (var sCat in serverCategories) {
        final serverId = sCat['categoryId'] ?? sCat['id'];
        final name = sCat['name'] ?? sCat['categoryName'];
        final color = sCat['color'];
        final type = sCat['scheduleType'] ?? 'ROUTINE';

        if (serverId == null || name == null) continue;

        final localCats =
            await (database.select(database.categories)
              ..where((c) => c.name.equals(name) & c.type.equals(type))).get();

        for (var lCat in localCats) {
          if (lCat.id != serverId) {
            if (type == 'ROUTINE') {
              await database.customStatement(
                'UPDATE routines SET category_id = ? WHERE category_id = ?',
                [serverId, lCat.id],
              );
            } else {
              await database.customStatement(
                'UPDATE todos SET category_id = ? WHERE category_id = ?',
                [serverId, lCat.id],
              );
            }

            await (database.delete(database.categories)
              ..where((c) => c.id.equals(lCat.id))).go();
          }
        }

        await database
            .into(database.categories)
            .insertOnConflictUpdate(
              db.CategoriesCompanion.insert(
                id: Value(serverId),
                name: name,
                type: type,
                color: color ?? '#000000',
              ),
            );
      }

      setState(() {});
    } catch (e) {
      print("카테고리 정리 중 에러 발생: $e");
    }
  }

  Future<void> _syncDailyApiDataToLocalDb(
    DailyScheduleData data,
    DateTime date,
  ) async {
    final database = db.LocalDatabaseSingleton.instance;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    await database.transaction(() async {
      final serverScheduleIds =
          data.todoList
              .where(
                (t) =>
                    t.scheduleType.toUpperCase() == 'TO_DO' && t.todo != null,
              )
              .map((t) => t.scheduleId)
              .toSet();

      final startOfToday = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfToday = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final localTodos =
          await (database.select(database.todos)..where((t) {
            return t.date.isBetweenValues(startOfToday, endOfToday);
          })).get();

      for (final local in localTodos) {
        if (local.isSynced && !serverScheduleIds.contains(local.id)) {
          await (database.delete(database.todos)
            ..where((t) => t.id.equals(local.id))).go();
        }
      }

      for (var item in data.todoList) {
        if (item.scheduleType.toUpperCase() != 'TO_DO' || item.todo == null)
          continue;
        if (item.content.trim() == item.category.categoryName.trim()) continue;

        int? timeMin;
        if (item.time != null && item.time!.contains(':')) {
          try {
            final p = item.time!.split(':');
            timeMin = int.parse(p[0]) * 60 + int.parse(p[1]);
          } catch (e) {}
        }

        await database
            .into(database.todos)
            .insertOnConflictUpdate(
              db.TodosCompanion.insert(
                id: Value(item.scheduleId),
                scheduleId: Value(item.scheduleId),
                todoServerId: Value(item.todo?.todoId),
                content: item.content,
                date: DateTime(
                  date.year,
                  date.month,
                  date.day,
                  (timeMin ?? 0) ~/ 60,
                  (timeMin ?? 0) % 60,
                ),
                colorType: Value(_parseColorType(item.category.color).index),
                isDone: Value(item.todo!.status),
                timeMinutes: Value(timeMin),
                categoryId: Value(item.category.id),
                isSynced: const Value(true),
              ),
            );
      }

      for (var item in data.routineList) {
        int uiId = item.scheduleId;
        int apiId = uiId;
        bool isDone = false;
        if (item.routineByDateList.isNotEmpty) {
          final m = item.routineByDateList.where((e) => e.date == dateString);
          if (m.isNotEmpty) {
            apiId = m.first.routineId;
            isDone = m.first.status;
          }
        }
        final weekStr = _convertWeekDaysListToString(item.repeatWeek);
        if (weekStr.isEmpty) continue;

        await database
            .into(database.routines)
            .insertOnConflictUpdate(
              db.RoutinesCompanion(
                id: Value(uiId),
                scheduleId: Value(uiId),
                routineId: Value(apiId),
                content: Value(item.content),
                colorType: Value(_parseColorType(item.category.color).index),
                weekDays: Value(weekStr),
                categoryId: Value(item.category.id),
                startDate: Value(DateTime(2024, 1, 1)),
                isSynced: const Value(true),
                endDate: Value(
                  DateTime.tryParse(item.date) ?? DateTime(3000, 12, 31),
                ),
                timeMinutes: Value(_parseTimeToMinutes(item.time)),
              ),
            );
        final completedIds = await database.getCompletedRoutineIds(date);
        if (isDone != completedIds.contains(uiId)) {
          await database.toggleRoutineCompletion(uiId, date);
        }
      }
    });

    await _loadDataForMonth(date);
    await _loadDataForDate(date);

    if (mounted) setState(() {});
  }

  Future<void> _fetchMonthlyDataAndRefresh(DateTime date) async {
    try {
      final yearMonth = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      final apiResult = await _calendarService.getMonthlySchedule(yearMonth);

      await _syncApiDataToLocalDb(apiResult);

      await _loadDataForMonth(date);
      await _loadDataForDate(date);
    } catch (e) {
      print("서버 동기화 실패(오프라인 상태일 수 있음) : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreenBody(
        calendarLayerLink: _calendarlayerLink,
        routineLayerLink: _routineLayerLink,
        routinesNotifier: _routinesNotifier,
        todosNotifier: _todosNotifier,
        selectedDateNotifier: _selectedDateNotifier,
        hideRoutineUI: _hideRoutineUI,
        hideTodoUI: _hideTodoUI,
        onDateChanged: _onDateChanged,
        calendarTodosNotifier: _calendarTodosNotifier,
        onPageChanged: _loadDataForMonth,

        onRoutineAdded: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
        onTodoAdded: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
        onDataChanged: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await _loadDataForMonth(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
      ),
      DaylogScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        showTodoSheet:
            widget.showTodoSheetForDaylog && !_hasShownInitialTodoSheet,
        onTodoSheetShown: () {
          setState(() {
            _hasShownInitialTodoSheet = true;
          });
        },
        selectedDate: _selectedDateNotifier.value,
        routines: _routinesNotifier.value,
        todos: _todosNotifier.value,
      ),
      MyScreen(
        onTabChange: _onTabChange,
        selectedDateNotifier: _selectedDateNotifier,
        onDataChanged: () async {
          await _loadDataForDate(_selectedDateNotifier.value);
          await WidgetUpdater.update();
        },
      ),
    ];
    if (_isInitialLoading) {
      return Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: OhmoBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onTabChange: _onTabChange,
        ),
      );
    }
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: OhmoBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}

// ------------------- HomeScreenBody -------------------

class HomeScreenBody extends StatefulWidget {
  final ValueNotifier<List<Routine>> routinesNotifier;
  final ValueNotifier<List<Todo>> todosNotifier;
  final ValueNotifier<DateTime> selectedDateNotifier;
  final ValueNotifier<Map<DateTime, List<Todo>>> calendarTodosNotifier;
  final void Function(DateTime)? onPageChanged;
  final VoidCallback? onDataChanged;
  final Future<void> Function()? onRoutineAdded;
  final Future<void> Function()? onTodoAdded;
  final ValueChanged<DateTime>? onDateChanged;
  final bool hideRoutineUI;
  final bool hideTodoUI;
  final LayerLink calendarLayerLink;
  final LayerLink routineLayerLink;

  const HomeScreenBody({
    Key? key,
    required this.routinesNotifier,
    required this.todosNotifier,
    required this.selectedDateNotifier,
    required this.calendarTodosNotifier,
    this.onPageChanged,
    this.onDataChanged,
    this.onRoutineAdded,
    this.onTodoAdded,
    this.onDateChanged,
    this.hideRoutineUI = false,
    this.hideTodoUI = false,
    required this.calendarLayerLink,
    required this.routineLayerLink,
  }) : super(key: key);

  @override
  _HomeScreenBodyState createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    widget.selectedDateNotifier.value = selectedDate;
    widget.onDateChanged?.call(selectedDate);
  }

  bool _isRoutineVisible(Routine routine, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      routine.startDate!.year,
      routine.startDate!.month,
      routine.startDate!.day,
    );
    final end =
        routine.endDate == null
            ? DateTime(3000, 12, 31)
            : DateTime(
              routine.endDate!.year,
              routine.endDate!.month,
              routine.endDate!.day,
            );

    bool isDateRangePass = !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
    bool isWeekDayPass = routine.daysOfWeek.contains(dateOnly.weekday);

    final isVisible =
        !dateOnly.isBefore(start) &&
        !dateOnly.isAfter(end) &&
        routine.daysOfWeek.contains(dateOnly.weekday);

    return isVisible;
  }

  bool _isTodoVisible(Todo todo, DateTime date) {
    final todoDate = DateTime(todo.Date.year, todo.Date.month, todo.Date.day);
    final selected = DateTime(date.year, date.month, date.day);
    return todoDate == selected;
  }

  Future<void> _showTodoAlarmSheet(Todo todo) async {
    final currentTodo = await db.LocalDatabaseSingleton.instance.getTodoById(
      todo.id,
    );
    if (currentTodo == null || !mounted) return;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(59),
          topLeft: Radius.circular(59),
        ),
      ),
      builder:
          (context) => TodoAlarm(
            currentDate: currentTodo.date,
            todoId: currentTodo.id,
            onDataChanged: widget.onDataChanged,
          ),
    );

    if (result != null && result is DateTime) {
      await db.LocalDatabaseSingleton.instance.updateTodoDate(
        currentTodo.id,
        result,
      );
      widget.onDataChanged?.call();
    } else if (result != null && result == 0) {
      await db.LocalDatabaseSingleton.instance.updateTodo(
        db.TodosCompanion(id: Value(currentTodo.id), alarmMinutes: Value(null)),
      );
      await NotificationService().cancelNotification(currentTodo.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('알람이 삭제되었습니다!')));
      }
      widget.onDataChanged?.call();
    } else if (result != null && result is int && result > 0) {
      final minutes = result;

      if (currentTodo.timeMinutes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시간이 설정된 투두만 미리 알림이 가능합니다.')),
          );
        }
        return;
      }

      final DateTime baseDate = DateTime(
        currentTodo.date.year,
        currentTodo.date.month,
        currentTodo.date.day,
      );
      final DateTime actualTodoTime = baseDate.add(
        Duration(minutes: currentTodo.timeMinutes!),
      );
      final DateTime notificationTime = actualTodoTime.subtract(
        Duration(minutes: minutes),
      );

      final String alarmTimeStr = DateFormat(
        'HH:mm:ss',
      ).format(notificationTime);

      try {
        final todoService = TodoService();

        final isServerSuccess = await todoService.updateAlarmTime(
          currentTodo.scheduleId!,
          alarmTimeStr,
        );

        if (isServerSuccess) {
          await db.LocalDatabaseSingleton.instance.updateTodo(
            db.TodosCompanion(
              id: Value(currentTodo.id),
              alarmMinutes: Value(minutes),
            ),
          );

          await NotificationService().cancelNotification(currentTodo.id);

          if (notificationTime.isAfter(DateTime.now())) {
            final originalTimeStr = DateFormat('HH:mm').format(actualTodoTime);

            await NotificationService().scheduleNotification(
              id: currentTodo.id,
              title: '오늘의 할 일!',
              body: '[To-do] $originalTimeStr ${currentTodo.content}',
              scheduledTime: notificationTime,
              payload: 'todo_${currentTodo.id}',
            );

            try {
              await (db.LocalDatabaseSingleton.instance.delete(
                db.LocalDatabaseSingleton.instance.notifications,
              )..where(
                (tbl) => tbl.content.like('%${currentTodo.content}%'),
              )).go();

              await db.LocalDatabaseSingleton.instance
                  .into(db.LocalDatabaseSingleton.instance.notifications)
                  .insert(
                    db.NotificationsCompanion.insert(
                      type: 'calender',
                      content:
                          '[To-do] $originalTimeStr ${currentTodo.content}',
                      timestamp: notificationTime,
                      isRead: const Value(false),
                    ),
                  );
            } catch (e) {}
          } else {
            print('알람 시각이 이미 지났습니다.');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${minutes}분 전 알람이 설정되었습니다!')),
            );
          }
          widget.onDataChanged?.call();
        } else {
          print('서버 응답 실패');
        }
      } catch (e) {
        print("오류: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: ValueListenableBuilder<DateTime>(
        valueListenable: widget.selectedDateNotifier,
        builder: (context, selectedDate, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<List<db.Notification>>(
                  stream:
                      db.LocalDatabaseSingleton.instance
                          .watchAllNotifications(),
                  builder: (context, snapshot) {
                    final notifications = snapshot.data ?? [];
                    final now = DateTime.now();

                    final int unreadCount =
                        notifications.where((n) {
                          final isTimeArrived =
                              n.timestamp.isBefore(now) ||
                              n.timestamp.isAtSameMomentAs(now);
                          return !n.isRead && isTimeArrived;
                        }).length;
                    final bool hasUnread = unreadCount > 0;

                    return ValueListenableBuilder<Map<DateTime, List<Todo>>>(
                      valueListenable: widget.calendarTodosNotifier,
                      builder: (context, calendarEvents, child) {
                        return MainCalendar(
                          layerLink: widget.calendarLayerLink,
                          selectedDate: selectedDate,
                          onDaySelected: onDaySelected,
                          eventLoader: (day) {
                            final normalizedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );
                            final events = calendarEvents[normalizedDay] ?? [];
                            return events;
                          },
                          onPageChanged: widget.onPageChanged,
                          hasUnread: hasUnread,
                          onGroupIconPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreenToGroupScreen(),
                              ),
                            );
                          },
                          onAlarmIconPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      if (!widget.hideRoutineUI) ...[
                        RoutineBanner(
                          layerLink: widget.routineLayerLink,
                          onAddPressed: () {
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
                              builder:
                                  (_) => RoutineBottomSheet(
                                    groupId: null,
                                    onRoutineAdded:
                                        widget.onRoutineAdded ?? () async {},
                                    selectedDate: selectedDate,
                                  ),
                            );
                          },
                        ),
                        ValueListenableBuilder<List<Routine>>(
                          valueListenable: widget.routinesNotifier,
                          builder: (context, routines, _) {
                            final visibleRoutines =
                                routines
                                    .where(
                                      (r) => _isRoutineVisible(r, selectedDate),
                                    )
                                    .toList();
                            return Column(
                              children:
                                  visibleRoutines
                                      .map(
                                        (routine) => RoutineCard(
                                          selectedDate: selectedDate,
                                          content: routine.content,
                                          colorType: routine.colorType,
                                          scheduleId: routine.id,
                                          isDone: routine.isDone,
                                          onDataChanged: widget.onDataChanged,

                                          onStatusChanged: () async {
                                            widget.onDataChanged?.call();
                                          },

                                          isColorPickerEnabled: false,
                                          onEditPressed: () {
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
                                              builder:
                                                  (_) => RoutineBottomSheet(
                                                    routineIdToEdit: routine.id,
                                                    onRoutineAdded:
                                                        widget.onRoutineAdded,
                                                    onDataChanged: () async {
                                                      widget.onDataChanged
                                                          ?.call();
                                                    },
                                                    selectedDate: selectedDate,
                                                  ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ],
                      if (!widget.hideRoutineUI && !widget.hideTodoUI) ...[
                        SizedBox(height: 20),
                        Divider(color: Colors.grey),
                      ],
                      if (!widget.hideTodoUI) ...[
                        TodoBanner(
                          onAddPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(59),
                                  topLeft: Radius.circular(59),
                                ),
                              ),
                              builder:
                                  (_) => TodoBottomSheet(
                                    selectedDate: selectedDate,
                                    onTodoAdded:
                                        widget.onTodoAdded ?? () async {},
                                  ),
                            );
                          },
                        ),
                        ValueListenableBuilder<List<Todo>>(
                          valueListenable: widget.todosNotifier,
                          builder: (context, todos, _) {
                            final visibleTodos =
                                todos
                                    .where(
                                      (t) => _isTodoVisible(t, selectedDate),
                                    )
                                    .toList();
                            return Column(
                              children:
                                  visibleTodos
                                      .map(
                                        (todo) => TodoCard(
                                          content: todo.content,
                                          colorType: todo.colorType,
                                          scheduleId: todo.id,
                                          isDone: todo.isDone,
                                          onDataChanged: widget.onDataChanged,
                                          onStatusChanged: () async {
                                            final localDb =
                                                db
                                                    .LocalDatabaseSingleton
                                                    .instance;
                                            final todoService = TodoService();
                                            final profile =
                                                Provider.of<ProfileData>(
                                                  context,
                                                  listen: false,
                                                );

                                            final newIsDone = !todo.isDone;

                                            await localDb.updateTodo(
                                              db.TodosCompanion(
                                                id: Value(todo.id),
                                                isDone: Value(newIsDone),
                                                isSynced: const Value(false),
                                              ),
                                            );

                                            await localDb.toggleTodoCompletion(
                                              todo.id,
                                              widget.selectedDateNotifier.value,
                                            );

                                            widget.onDataChanged?.call();

                                            if (!profile.isGuest) {
                                              try {
                                                final serverId =
                                                    todo.todoServerId;
                                                if (serverId != null &&
                                                    serverId != 0) {
                                                  final serverResult =
                                                      await todoService
                                                          .toggleTodoStatus(
                                                            serverId,
                                                          );

                                                  if (serverResult != null) {
                                                    await localDb.updateTodo(
                                                      db.TodosCompanion(
                                                        id: Value(todo.id),
                                                        isSynced: const Value(
                                                          true,
                                                        ),
                                                      ),
                                                    );

                                                    if (serverResult !=
                                                        newIsDone) {
                                                      await localDb.updateTodo(
                                                        db.TodosCompanion(
                                                          id: Value(todo.id),
                                                          isDone: Value(
                                                            serverResult,
                                                          ),
                                                        ),
                                                      );
                                                      widget.onDataChanged
                                                          ?.call();
                                                    }
                                                  }
                                                }
                                              } catch (e) {
                                                print("투두 상태 서버 동기화 실패: $e");
                                                await localDb.updateTodo(
                                                  db.TodosCompanion(
                                                    id: Value(todo.id),
                                                    isDone: Value(!newIsDone),
                                                    isSynced: const Value(true),
                                                  ),
                                                );
                                                await localDb
                                                    .toggleTodoCompletion(
                                                      todo.id,
                                                      widget
                                                          .selectedDateNotifier
                                                          .value,
                                                    );
                                                widget.onDataChanged?.call();
                                              }
                                            } else {}
                                          },
                                          onDateChanged: (id, newDate) async {
                                            await db
                                                .LocalDatabaseSingleton
                                                .instance
                                                .updateTodoDate(id, newDate);
                                            widget.onDataChanged?.call();
                                          },
                                          isColorPickerEnabled: false,
                                          onEditPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: true,
                                              backgroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                59,
                                                              ),
                                                          topLeft:
                                                              Radius.circular(
                                                                59,
                                                              ),
                                                        ),
                                                  ),
                                              builder:
                                                  (_) => TodoBottomSheet(
                                                    todoIdToEdit: todo.id,
                                                    selectedDate: selectedDate,
                                                    onTodoAdded:
                                                        widget.onTodoAdded,
                                                    onDataChanged: () async {
                                                      widget.onDataChanged
                                                          ?.call();
                                                    },
                                                  ),
                                            );
                                          },
                                          onAlarmPressed: () {
                                            _showTodoAlarmSheet(todo);
                                          },
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
