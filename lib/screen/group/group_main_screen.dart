import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ohmo/component/group_routine_bottom_sheet.dart';
import 'package:ohmo/const/colors.dart';
import 'package:ohmo/db/drift_database.dart';
import 'package:ohmo/services/group_sse_service.dart';
import '../../component/color_palette_bottom_sheet.dart';
import '../../component/delete_bottom_sheet.dart';
import '../../component/group_routine_card.dart';
import '../../component/group_settings_bottom_sheet.dart';
import '../../component/group_todo_bottom_sheet.dart';
import '../../component/group_todo_card.dart';
import '../../component/main_calendar.dart';
import '../../component/routine_banner.dart';
import '../../component/todo_banner.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/group_service.dart';

class CalendarEvent {
  final int id;
  final String content;
  final int currentCompletion;
  final int requiredCompletion;

  CalendarEvent({
    required this.id,
    required this.content,
    required this.currentCompletion,
    required this.requiredCompletion,
  });

  bool isFullyCompleted() {
    return requiredCompletion > 0 && currentCompletion >= requiredCompletion;
  }

  @override
  String toString() => content;
}

class GroupMainScreen extends StatefulWidget {
  final int groupId;

  const GroupMainScreen({super.key, required this.groupId});

  @override
  State<GroupMainScreen> createState() => _GroupMainScreenState();
}

class _GroupMainScreenState extends State<GroupMainScreen> {
  final GroupService _groupService = GroupService();
  final GroupSseService _sseService = GroupSseService();
  DateTime selectedDate = DateTime.now();
  late final LocalDatabase _db;
  Set<int> _completedRoutineIds = {};
  Set<int> _completedTodoIds = {};
  Map<int, int> _todoRealIdMap = {};

  final ValueNotifier<List<Routine>> _routinesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Todo>> _todosNotifier = ValueNotifier([]);
  ColorType _currentColor = ColorType.pinkLight;
  int _memberCount = 0;
  int _actualMemberCount = 0;
  Map<int, int> _routineCompletionCounts = {};
  Map<int, int> _todoCompletionCounts = {};
  Map<int, int?> _todoAssigneeIdMap = {};
  String _groupName = '...';
  StreamSubscription<String>? _sseSubscription;

  Map<DateTime, List<CalendarEvent>> _eventsCache = {};
  bool _needsRefresh = false;

  int? _myMemberGroupId;
  String? _myNickname;

  @override
  void initState() {
    super.initState();
    _db = LocalDatabaseSingleton.instance;
    _fetchGroupData(selectedDate);
    _loadSchedulesForMonth(selectedDate);
    //_startSseSubscription();
  }

  @override
  void dispose() {
    // _sseSubscription?.cancel();
    super.dispose();
  }

  void _startSseSubscription() {
    _sseSubscription = _sseService
        .subscribeGroup(widget.groupId)
        .listen(
          (event) {
            print("[실시간 알람 수신] : $event");

            if (mounted) {
              _refreshAllData(selectedDate);
            }
          },
          onError: (err) => print("SSE 스트림 에러 : $err"),
          cancelOnError: false,
        );
  }

  Future<void> _refreshAllData(DateTime date) async {
    await _loadSchedulesForMonth(date);
    await _fetchGroupData(date);
  }

  Future<void> _loadSchedulesForMonth(DateTime month) async {
    final String yearMonth = DateFormat('yyyy-MM').format(month);

    try {
      final List<dynamic> monthlyData = await _groupService.fetchNoticesByMonth(
        groupId: widget.groupId,
        yearMonth: yearMonth,
      );

      Map<DateTime, List<CalendarEvent>> tempEvents = {};

      for (var dayData in monthlyData) {
        final String? dateStr = dayData['date'];
        if (dateStr == null) continue;

        final DateTime noticeDate = DateTime.parse(dayData['date']);
        final dateOnly = DateTime.utc(
          noticeDate.year,
          noticeDate.month,
          noticeDate.day,
        );

        final List<dynamic> noticesJson = dayData['notices'] ?? [];

        tempEvents[dateOnly] =
            noticesJson
                .map(
                  (nj) => CalendarEvent(
                    id: nj['id'] ?? nj['noticeId'] ?? 0,
                    content: nj['notice'] ?? '',
                    currentCompletion: 0,
                    requiredCompletion: 1,
                  ),
                )
                .toList();
      }

      if (mounted) {
        setState(() {
          _eventsCache = tempEvents;
        });
      }
    } catch (e) {
      print('월별 공지 로딩 에러: $e');
    }
  }

  Future<void> _fetchGroupData(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final scheduleData = await _groupService.fetchGroupSchedules(
      groupId: widget.groupId,
      date: dateString,
    );

    final group = await _groupService.getGroupDetail(widget.groupId);
    if (group == null) return;

    final localGroup = await _db.getGroupById(widget.groupId);

    ColorType colorToApply;
    if (localGroup?.localColor != null) {
      colorToApply = ColorTypeExtension.fromString(localGroup!.localColor!);
    } else {
      colorToApply = ColorTypeExtension.fromString(
        group['groupColor'] ?? 'pinkLight',
      );
    }

    final memberData = await _groupService.fetchGroupMembers(widget.groupId);
    int currentActualCount = 0;
    if (memberData != null) {
      final List<dynamic> actualMembers =
          memberData['memberGroupInfos'] ?? memberData['memberDtoList'] ?? [];
      currentActualCount = actualMembers.length;
    }

    int? currentMyGroupId = group['memberGroupId'];
    if (currentMyGroupId == null && memberData != null) {
      final myEmail = await _groupService.getMyEmail();
      final List<dynamic> members =
          memberData['memberGroupInfos'] ?? memberData['memberDtoList'] ?? [];
      try {
        final me = members.firstWhere(
          (m) => m['memberInfo']['email'] == myEmail,
        );
        currentMyGroupId = me['memberGroupId'];
        _myNickname = me['nickname'];
      } catch (e) {}
    }

    if (scheduleData == null) return;

    final List<dynamic> apiTodos = scheduleData['todos'] ?? [];
    final List<dynamic> apiRoutines = scheduleData['routines'] ?? [];

    List<Todo> mappedTodos = [];
    List<Routine> mappedRoutines = [];
    Map<int, int> tempTodoCounts = {};
    Map<int, int> tempRoutineCounts = {};
    Set<int> tempCompletedTodoIds = {};
    Set<int> tempCompletedRoutineIds = {};

    for (var item in apiTodos) {
      final int scheduleId = item['scheduleId'];
      final groupTodo = item['groupTodoWithAssignee'] ?? {};
      final todoInfo = groupTodo['todo'] ?? {};
      final List<dynamic> assignees = groupTodo['memberGroupInfos'] ?? [];

      // 1. 수정용 ID (진짜 투두 번호)
      final int realServerTodoId = todoInfo['todoId'] ?? 0;

      int? myAssigneeId;
      bool myStatus = false;

      if (_myMemberGroupId != null) {
        for (var a in assignees) {
          final mgi = a['memberGroupInfo'] ?? {};
          if (mgi['memberGroupId'].toString() == _myMemberGroupId.toString()) {
            myAssigneeId = a['assigneeId'];
            myStatus = a['status'] ?? false;
            break;
          }
        }
      }

      int finalId = myAssigneeId ?? scheduleId;

      _todoRealIdMap[finalId] = realServerTodoId;

      int totalDoneCount =
          todoInfo['doneCount'] ??
          assignees.where((a) => a['status'] == true).length;

      mappedTodos.add(
        Todo(
          id: finalId,
          content: item['content'] ?? '',
          date: DateTime.parse(item['date']),
          groupId: widget.groupId,
          colorType:
              ColorTypeExtension.fromString(
                item['category']?['color'] ?? 'pinkLight',
              ).index,
          isDone: myStatus,
          scheduleType: 'TO_DO',
          isSynced: true,
          isDeleted: false,
        ),
      );

      tempTodoCounts[finalId] = totalDoneCount;
      if (myStatus && finalId != 0) tempCompletedTodoIds.add(finalId);
    }

    Map<String, Set<String>> routineWeeksGroup = {};

    for (var item in apiRoutines) {
      final content = item['content'] ?? '내용없음';
      final groupRoutine = item['groupRoutineWithAssignee'] ?? {};
      final routineData = groupRoutine['routine'] ?? {};

      String dayNum = _mapEngDayToNum(routineData['week'] ?? '');

      if (!routineWeeksGroup.containsKey(content)) {
        routineWeeksGroup[content] = {};
      }
      if (dayNum.isNotEmpty) {
        routineWeeksGroup[content]!.add(dayNum);
      }
    }
    for (var item in apiRoutines) {
      final content = item['content'] ?? '내용없음';
      final groupRoutine = item['groupRoutineWithAssignee'] ?? {};
      final routineData = groupRoutine['routine'] ?? {};
      final List<dynamic> assignees = groupRoutine['memberGroupInfos'] ?? [];

      String combinedWeekDays =
          routineWeeksGroup[content]?.toList().join(',') ?? '';

      final int actualServerRoutineId =
          routineData['routineId'] ?? item['routineId'] ?? 0;
      final int actualScheduleId = item['scheduleId'] ?? 0;

      int? myAssigneeId;
      bool myStatus = false;

      if (_myMemberGroupId != null) {
        for (var a in assignees) {
          final mgi = a['memberGroupInfo'] ?? {};
          if (mgi['memberGroupId'].toString() == _myMemberGroupId.toString()) {
            myAssigneeId = a['assigneeId'];
            myStatus = a['status'] ?? false;
            break;
          }
        }
      }

      int finalId = myAssigneeId ?? 0;

      if (finalId == 0 &&
          (content.contains('@모두') || content.contains('@모든'))) {
        finalId = item['scheduleId'];
      }

      int totalDoneCount =
          routineData['doneCount'] ??
          assignees.where((a) => a['status'] == true).length;

      mappedRoutines.add(
        Routine(
          id: finalId,
          routineId: actualServerRoutineId,
          scheduleId: actualScheduleId,
          content: content,
          groupId: widget.groupId,
          startDate: DateTime.parse(item['date']),
          endDate: DateTime.now().add(const Duration(days: 90)),
          weekDays: combinedWeekDays,
          colorType:
              ColorTypeExtension.fromString(
                item['category']?['color'] ?? 'pinkLight',
              ).index,
          isDone: myStatus,
          scheduleType: 'ROUTINE',
          isSynced: true,
          isDeleted: false,
        ),
      );

      tempRoutineCounts[finalId] = totalDoneCount;
      if (myStatus && finalId != 0) tempCompletedRoutineIds.add(finalId);
    }

    bool hasItems = mappedTodos.isNotEmpty || mappedRoutines.isNotEmpty;
    bool allTodosDone = mappedTodos.every((t) => t.isDone);
    bool allRoutinesDone = mappedRoutines.every((r) => r.isDone);
    bool isDayFullyCleared = hasItems && allTodosDone && allRoutinesDone;

    if (mounted) {
      setState(() {
        _myMemberGroupId = currentMyGroupId;
        _currentColor = colorToApply;
        _groupName = group['groupName'] ?? '이름 없음';
        _actualMemberCount = currentActualCount;
        _memberCount = currentActualCount;
        _completedTodoIds = tempCompletedTodoIds;
        _completedRoutineIds = tempCompletedRoutineIds;
        _todoCompletionCounts = tempTodoCounts;
        _routineCompletionCounts = tempRoutineCounts;

        final dateOnly = DateTime.utc(date.year, date.month, date.day);
        Map<DateTime, List<CalendarEvent>> updatedCache = Map.from(
          _eventsCache,
        );

        if (isDayFullyCleared) {
          if (updatedCache.containsKey(dateOnly) &&
              updatedCache[dateOnly]!.isNotEmpty) {
            updatedCache[dateOnly] =
                updatedCache[dateOnly]!.map((event) {
                  return CalendarEvent(
                    id: event.id,
                    content: event.content,
                    currentCompletion: 1,
                    requiredCompletion: 1,
                  );
                }).toList();
          } else {
            updatedCache[dateOnly] = [
              CalendarEvent(
                id: -999,
                content: '',
                currentCompletion: 1,
                requiredCompletion: 1,
              ),
            ];
          }
        } else {
          if (updatedCache.containsKey(dateOnly)) {
            updatedCache[dateOnly]!.removeWhere((e) => e.id == -999);

            updatedCache[dateOnly] =
                updatedCache[dateOnly]!.map((event) {
                  return CalendarEvent(
                    id: event.id,
                    content: event.content,
                    currentCompletion: 0,
                    requiredCompletion: 1,
                  );
                }).toList();
          }
        }
        _eventsCache = updatedCache;
      });
      _todosNotifier.value = mappedTodos;
      _routinesNotifier.value = mappedRoutines;
    }
  }

  String _mapEngDayToNum(dynamic englishWeeks) {
    if (englishWeeks == null) return '';

    const Map<String, String> dayMap = {
      "MONDAY": "1",
      "TUESDAY": "2",
      "WEDNESDAY": "3",
      "THURSDAY": "4",
      "FRIDAY": "5",
      "SATURDAY": "6",
      "SUNDAY": "7",
    };

    if (englishWeeks is List) {
      return englishWeeks
          .map((e) => dayMap[e.toString().toUpperCase()] ?? '')
          .where((e) => e.isNotEmpty)
          .join(',');
    } else {
      return dayMap[englishWeeks.toString().toUpperCase()] ?? '';
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });
    _fetchGroupData(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _needsRefresh);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context, _needsRefresh),
          ),
          backgroundColor: ColorManager.getColor(_currentColor),
        ),
        backgroundColor: ColorManager.getColor(_currentColor),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(children: [_buildGroupName(), Spacer(), _buildSetting()]),
                SizedBox(height: 10.0),
                NoticeSection(
                  groupId: widget.groupId,
                  onNoticeChanged: () => _refreshAllData(selectedDate),
                ),
                SizedBox(height: 10.0),
                _buildGroupCalendar(),
                SizedBox(height: 60.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Text(
        _groupName,
        style: TextStyle(fontFamily: 'PretendardRegular', fontSize: 24.0),
      ),
    );
  }

  Widget _buildSetting() {
    return IconButton(
      onPressed: () async {
        final result = await showModalBottomSheet<dynamic>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(59),
              topRight: Radius.circular(59),
            ),
          ),
          builder:
              (_) => GroupSettingsBottomSheet(
                groupId: widget.groupId,
                groupName: _groupName,
                onColorChanged: (newColor) {
                  setState(() {
                    _currentColor = newColor;
                  });
                },
              ),
        );
        if (result == true || result is ColorType) {
          _needsRefresh = true;
          await _fetchGroupData(selectedDate);
        } else if (result == 'leave') {
          _needsRefresh = true;
          if (mounted) Navigator.pop(context, _needsRefresh);
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      constraints: const BoxConstraints(),
      icon: SvgPicture.asset('android/assets/images/setting.svg'),
    );
  }

  Widget _buildGroupCalendar() {
    return Container(
      width: 318,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          MainCalendar(
            selectedDate: selectedDate,
            onDaySelected: onDaySelected,
            eventLoader: (day) {
              final dateOnly = DateTime.utc(day.year, day.month, day.day);

              if (day.day == 1) {}

              final events = _eventsCache[dateOnly] ?? [];
              if (events.isNotEmpty) {}
              return events;
            },
            onPageChanged: (focusedDay) => _loadSchedulesForMonth(focusedDay),
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 15.0,
            ),
            headerTextStyle: TextStyle(
              fontFamily: 'RubikSprayPaint',
              fontSize: 24.0,
            ),
            formatButtonSize: 17.0,
            monthButtonOffset: Offset(30, -5),
            weekButtonOffset: Offset(5, -5),
            dayFontSize: 14.0,
            calendarPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            headerDateFormat: '  MMM',
            onAlarmIconPressed: null,
            hasUnread: false,
            markerColor: _currentColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: RoutineBanner(
              onAddPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(59),
                      topRight: Radius.circular(59),
                    ),
                  ),
                  builder:
                      (_) => GroupRoutineBottomSheet(
                        groupId: widget.groupId,
                        onRoutineAdded: () async {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          await _fetchGroupData(selectedDate);
                        },
                        selectedDate: selectedDate,
                      ),
                );
              },
              addButtonOffset: Offset(3, 0),
            ),
          ),
          ValueListenableBuilder<List<Routine>>(
            valueListenable: _routinesNotifier,
            builder: (context, routines, _) {
              if (routines.isEmpty) {
                return const SizedBox(height: 20);
              }
              return Column(
                children:
                    routines.map((routine) {
                      final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');
                      final mentions =
                          mentionRegex
                              .allMatches(routine.content)
                              .map((m) => m.group(0)!)
                              .toList();

                      final bool isCheckboxVisible =
                          mentions.contains('@모두') ||
                          routine.content.contains('@모두') ||
                          mentions.any(
                            (m) =>
                                _myNickname != null && m.contains(_myNickname!),
                          );
                      final bool isIndicatorVisible =
                          mentions.isNotEmpty ||
                          routine.content.contains('@모두');
                      int finalTotalCount =
                          (mentions.isEmpty ||
                                  mentions.contains('@모두') ||
                                  routine.content.contains('@모두'))
                              ? _actualMemberCount
                              : mentions.length;

                      return GroupRoutineCard(
                        routine: routine,
                        myNickname: _myNickname,
                        memberGroupId: _myMemberGroupId,
                        isDoneForDay: _completedRoutineIds.contains(routine.id),
                        selectedDate: selectedDate,
                        totalMemberCount: finalTotalCount,
                        completedMemberCount:
                            _routineCompletionCounts[routine.id] ?? 0,
                        isIndicatorVisible: isIndicatorVisible,
                        isCheckboxVisible: isCheckboxVisible,
                        onDataChanged: () => _fetchGroupData(selectedDate),
                        onEditPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(59),
                                topRight: Radius.circular(59),
                              ),
                            ),
                            builder:
                                (_) => GroupRoutineBottomSheet(
                                  groupId: widget.groupId,
                                  routineIdToEdit: routine.scheduleId,
                                  routineToEdit: routine,
                                  selectedDate: selectedDate,
                                  onRoutineAdded: () async {
                                    await _fetchGroupData(selectedDate);
                                  },
                                ),
                          );
                        },
                      );
                    }).toList(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: TodoBanner(
              onAddPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(59),
                      topRight: Radius.circular(59),
                    ),
                  ),
                  builder:
                      (_) => GroupTodoBottomSheet(
                        groupId: widget.groupId,
                        onTodoAdded: () => _refreshAllData(selectedDate),
                        selectedDate: selectedDate,
                      ),
                );
              },
              addButtonOffset: Offset(4, 0),
            ),
          ),
          ValueListenableBuilder<List<Todo>>(
            valueListenable: _todosNotifier,
            builder: (context, todos, _) {
              if (todos.isEmpty) return const SizedBox(height: 20);
              return Column(
                children:
                    todos.map((todo) {
                      final mentionRegex = RegExp(r'@[\w\(\)가-힣]+');
                      final mentions =
                          mentionRegex
                              .allMatches(todo.content)
                              .map((m) => m.group(0)!)
                              .toList();
                      final bool isIndicatorVisible = mentions.isNotEmpty;
                      final bool isCheckboxVisible =
                          mentions.contains('@모두') ||
                          mentions.any((m) => m.contains(_myNickname ?? ""));
                      int totalCount =
                          (mentions.isEmpty || mentions.contains('@모두'))
                              ? _memberCount
                              : mentions.length;

                      return GroupTodoCard(
                        todo: todo,
                        todoIdForApi: _todoRealIdMap[todo.id],
                        assigneeId: _todoAssigneeIdMap[todo.id],
                        myNickname: _myNickname,
                        isDoneForDay: _completedTodoIds.contains(todo.id),
                        selectedDate: selectedDate,
                        totalMemberCount: totalCount,
                        completedMemberCount:
                            _todoCompletionCounts[todo.id] ?? 0,
                        isIndicatorVisible: isIndicatorVisible,
                        isCheckboxVisible: isCheckboxVisible,
                        onDataChanged: () => _refreshAllData(selectedDate),
                        onEditPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(59),
                                topRight: Radius.circular(59),
                              ),
                            ),
                            builder:
                                (_) => GroupTodoBottomSheet(
                                  groupId: widget.groupId,
                                  todoIdToEdit: _todoRealIdMap[todo.id],
                                  todoToEdit: todo,
                                  selectedDate: selectedDate,
                                  onTodoAdded:
                                      () => _refreshAllData(selectedDate),
                                ),
                          );
                        },
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NoticeSection extends StatefulWidget {
  final int groupId;
  final VoidCallback onNoticeChanged;

  const NoticeSection({
    super.key,
    required this.groupId,
    required this.onNoticeChanged,
  });

  @override
  State<NoticeSection> createState() => _NoticeSectionState();
}

class _NoticeSectionState extends State<NoticeSection> {
  final LocalDatabase _db = LocalDatabaseSingleton.instance;
  bool _isAddingNewNotice = false;
  bool _isLoading = false;
  final _newNoticeController = TextEditingController();
  List<Notice> _notices = [];
  DateTime? _selectedDate;
  int? _editingNoticeId;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  @override
  void dispose() {
    _newNoticeController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotices() async {
    setState(() => _isLoading = true);

    try {
      final String yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final groupService = GroupService();

      final List<dynamic> serverMonthlyData = await groupService
          .fetchNoticesByMonth(groupId: widget.groupId, yearMonth: yearMonth);

      List<Notice> mappedNotices = [];

      for (var dayData in serverMonthlyData) {
        final List<dynamic> noticesJson = dayData['notices'] ?? [];
        for (var json in noticesJson) {
          mappedNotices.add(
            Notice(
              id: json['id'] ?? json['noticeId'] ?? 0,
              content: json['notice'] ?? '',
              noticeDate: DateTime.parse(json['date']),
              groupId: json['groupId'] ?? widget.groupId,
              createdAt: DateTime.now(),
              isDeleted: false,
            ),
          );
        }
      }

      mappedNotices.sort((a, b) => b.noticeDate.compareTo(a.noticeDate));

      if (mounted) {
        setState(() {
          _notices = mappedNotices;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('공지사항 로드 중 오류 발생: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _startEditing(Notice notice) {
    setState(() {
      _isAddingNewNotice = true;
      _editingNoticeId = notice.id;
      _newNoticeController.text = notice.content;
      _selectedDate = notice.noticeDate;
    });
  }

  Future<void> _saveNotice() async {
    if (_isLoading) return;

    final content = _newNoticeController.text.trim();
    if (content.isEmpty || _selectedDate == null) return;

    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final groupService = GroupService();

    final bool isSuccess;

    if (_editingNoticeId != null) {
      isSuccess = await groupService.updateNotice(
        noticeId: _editingNoticeId!,
        notice: content,
        date: dateStr,
      );
    } else {
      isSuccess = await groupService.createNotice(
        groupId: widget.groupId,
        notice: content,
        date: dateStr,
      );
    }
    if (isSuccess) {
      final newNotice = NoticesCompanion.insert(
        content: content,
        createdAt: DateTime.now(),
        groupId: drift.Value(widget.groupId),
        noticeDate: _selectedDate!,
      );

      final int newNoticeId = await _db.insertNotice(newNotice);

      final group = await _db.getGroupById(widget.groupId);
      final groupName = group?.name ?? "ohmo";

      final noticeDateStr = DateFormat('MM/dd').format(_selectedDate!);

      String line1 = "'$groupName' 그룹에 새로운 공지가 등록되었습니다.";
      String line2 = "[공지] $content(일시 : $noticeDateStr)";

      final String multiLineContent = "$line1\n$line2";

      await _db.insertNotification(
        NotificationsCompanion(
          type: drift.Value('group'),
          content: drift.Value(multiLineContent),
          timestamp: drift.Value(DateTime.now()),
          relatedId: drift.Value(newNoticeId),
          isRead: drift.Value(true),
        ),
      );

      _newNoticeController.clear();
      setState(() {
        _isAddingNewNotice = false;
        _selectedDate = null;
      });
      _fetchNotices();
      widget.onNoticeChanged();
    } else {
      _showErrorSnackBar('서버 등록에 실패했습니다.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleTextStyle = TextStyle(
      fontFamily: 'RubikSprayPaint',
      fontSize: 16.0,
      color: Colors.white,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: 318,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Notice', style: titleTextStyle),
                Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _isAddingNewNotice = !_isAddingNewNotice;
                      if (_isAddingNewNotice) {
                        _selectedDate = DateTime.now();
                      } else {
                        _selectedDate = null;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: SvgPicture.asset(
                      'android/assets/images/plus.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            if (_notices.length > 2)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 53.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notices.length,
                  itemBuilder: (context, index) {
                    final notice = _notices[index];
                    return _buildNoticeItem(notice);
                  },
                ),
              )
            else
              ..._notices.map((notice) => _buildNoticeItem(notice)).toList(),
            if (_notices.isEmpty && !_isAddingNewNotice)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '등록된 공지사항이 없습니다.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

            if (_isAddingNewNotice) _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    final formattedDate = DateFormat('M/d').format(notice.noticeDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '$formattedDate',
              style: TextStyle(
                fontFamily: 'PretendardRegular',
                color: Colors.white,
                fontSize: 15,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _startEditing(notice),
              child: Text(
                notice.content,
                style: TextStyle(
                  fontFamily: 'PretendardSemibold',
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(59),
                    topLeft: Radius.circular(59),
                  ),
                ),
                builder: (BuildContext bContext) {
                  return DeleteBottomSheet(
                    title: '공지 삭제',
                    message: '해당 공지사항을 삭제하시겠어요?\n삭제된 공지는 복구할 수 없습니다.',
                    onDelete: () async {
                      final groupService = GroupService();

                      final bool isSuccess = await groupService.deleteNotice(
                        noticeId: notice.id,
                      );

                      if (isSuccess) {
                        final db = LocalDatabaseSingleton.instance;
                        await db.deleteNotice(notice.id);
                        _fetchNotices();
                        widget.onNoticeChanged();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("공지사항이 삭제되었습니다.")),
                          );
                        }
                      } else {
                        _showErrorSnackBar('서버에서 공지사항을 삭제하는 데 실패했습니다.');
                      }
                    },
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'android/assets/images/todo_alarm.svg',
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    if (_selectedDate == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('M/d').format(_selectedDate!),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _newNoticeController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '새로운 공지를 입력하세요',
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _selectedDate != null ? _saveNotice : null,
          ),
        ],
      ),
    );
  }
}
